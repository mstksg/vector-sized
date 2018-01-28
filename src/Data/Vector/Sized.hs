{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures             #-}
{-# LANGUAGE RankNTypes                 #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TypeOperators              #-}

{-|
This module re-exports the functionality in 'Data.Vector.Generic.Sized'
 specialized to 'Data.Vector'.

Functions returning a vector determine the size from the type context unless
they have a @'@ suffix in which case they take an explicit 'Proxy' argument.

Functions where the resultant vector size is not know until compile time are
not exported.
-}

module Data.Vector.Sized
 ( Vector
  , VM.MVector
   -- * Accessors
   -- ** Length information
  , length
  , length'
    -- ** Indexing
  , index
  , index'
  , unsafeIndex
  , head
  , last
    -- ** Monadic indexing
  , indexM
  , indexM'
  , unsafeIndexM
  , headM
  , lastM
    -- ** Extracting subvectors (slicing)
  , slice
  , slice'
  , init
  , tail
  , take
  , take'
  , drop
  , drop'
  , splitAt
  , splitAt'
    -- * Construction
    -- ** Initialization
  , empty
  , singleton
  , replicate
  , replicate'
  , generate
  , generate'
  , iterateN
  , iterateN'
    -- ** Monadic initialization
  , replicateM
  , replicateM'
  , generateM
  , generateM'
    -- ** Unfolding
  , unfoldrN
  , unfoldrN'
    -- ** Enumeration
  , enumFromN
  , enumFromN'
  , enumFromStepN
  , enumFromStepN'
    -- ** Concatenation
  , cons
  , snoc
  , (++)
    -- ** Restricting memory usage
  , force
    -- * Modifying vectors
    -- ** Bulk updates
  , (//)
  , update
  , update_
  , unsafeUpd
  , unsafeUpdate
  , unsafeUpdate_
    -- ** Accumulations
  , accum
  , accumulate
  , accumulate_
  , unsafeAccum
  , unsafeAccumulate
  , unsafeAccumulate_
    -- ** Permutations
  , reverse
  , backpermute
  , unsafeBackpermute
  -- * Lenses
  , ix
  , _head
  , _last
    -- * Elementwise operations
    -- ** Indexing
  , indexed
    -- ** Mapping
  , map
  , imap
  , concatMap
    -- ** Monadic mapping
  , mapM
  , imapM
  , mapM_
  , imapM_
  , forM
  , forM_
    -- ** Zipping
  , zipWith
  , zipWith3
  , zipWith4
  , zipWith5
  , zipWith6
  , izipWith
  , izipWith3
  , izipWith4
  , izipWith5
  , izipWith6
  , zip
  , zip3
  , zip4
  , zip5
  , zip6
    -- ** Monadic zipping
  , zipWithM
  , izipWithM
  , zipWithM_
  , izipWithM_
    -- ** Unzipping
  , unzip
  , unzip3
  , unzip4
  , unzip5
  , unzip6
    -- * Working with predicates
    -- ** Searching
  , elem
  , notElem
  , find
  , findIndex
  , elemIndex
    -- * Folding
  , foldl
  , foldl1
  , foldl'
  , foldl1'
  , foldr
  , foldr1
  , foldr'
  , foldr1'
  , ifoldl
  , ifoldl'
  , ifoldr
  , ifoldr'
    -- ** Specialised folds
  , all
  , any
  , and
  , or
  , sum
  , product
  , maximum
  , maximumBy
  , minimum
  , minimumBy
  , maxIndex
  , maxIndexBy
  , minIndex
  , minIndexBy
    -- ** Monadic folds
  , foldM
  , ifoldM
  , fold1M
  , foldM'
  , ifoldM'
  , fold1M'
  , foldM_
  , ifoldM_
  , fold1M_
  , foldM'_
  , ifoldM'_
  , fold1M'_
    -- ** Monadic sequencing
  , sequence
  , sequence_
    -- * Prefix sums (scans)
  , prescanl
  , prescanl'
  , postscanl
  , postscanl'
  , scanl
  , scanl'
  , scanl1
  , scanl1'
  , prescanr
  , prescanr'
  , postscanr
  , postscanr'
  , scanr
  , scanr'
  , scanr1
  , scanr1'
    -- * Conversions
    -- ** Lists
  , toList
  , fromList
  , fromListN
  , fromListN'
  , withSizedList
    -- ** Mutable vectors
  , freeze
  , thaw
  , copy
  , unsafeFreeze
  , unsafeThaw
    -- ** Unsized Vectors
  , toSized
  , withSized
  , fromSized
  , withVectorUnsafe
  ) where

import qualified Data.Vector.Generic.Sized as V
import qualified Data.Vector as VU
import qualified Data.Vector.Mutable.Sized as VM
import GHC.TypeLits
import Data.Finite
import Data.Proxy
import Control.Monad.Primitive
import Prelude hiding ( length, null,
                        replicate, (++), concat,
                        head, last,
                        init, tail, take, drop, splitAt, reverse,
                        map, concat, concatMap,
                        zipWith, zipWith3, zip, zip3, unzip, unzip3,
                        filter, takeWhile, dropWhile, span, break,
                        elem, notElem,
                        foldl, foldl1, foldr, foldr1,
                        all, any, and, or, sum, product, maximum, minimum,
                        scanl, scanl1, scanr, scanr1,
                        enumFromTo, enumFromThenTo,
                        mapM, mapM_, sequence, sequence_,
                        showsPrec )

-- | 'Data.Vector.Generic.Sized.Vector' specialized to use
-- 'Data.Vector'
type Vector = V.Vector VU.Vector

-- | /O(1)/ Yield the length of the vector as an 'Int'.
length :: forall n a. KnownNat n
       => Vector n a -> Int
length = V.length
{-# inline length #-}

-- | /O(1)/ Yield the length of the vector as a 'Proxy'.
length' :: forall n a. KnownNat n
        => Vector n a -> Proxy n
length' = V.length'
{-# inline length' #-}

-- | /O(1)/ Safe indexing using a 'Finite'.
index :: forall n a. KnownNat n
      => Vector n a -> Finite n -> a
index = V.index
{-# inline index #-}

-- | /O(1)/ Safe indexing using a 'Proxy'.
index' :: forall n m a p. (KnownNat n, KnownNat m)
       => Vector (n+m+1) a -> p n -> a
index' = V.index'
{-# inline index' #-}

-- | /O(1)/ Indexing using an Int without bounds checking.
unsafeIndex :: forall n a. KnownNat n
      => Vector n a -> Int -> a
unsafeIndex = V.unsafeIndex
{-# inline unsafeIndex #-}

-- | /O(1)/ Yield the first element of a non-empty vector.
head :: forall n a. Vector (1+n) a -> a
head = V.head
{-# inline head #-}

-- | /O(1)/ Yield the last element of a non-empty vector.
last :: forall n a. Vector (n+1) a -> a
last = V.last
{-# inline last #-}

-- | Lens to access (/O(1)/) and update (/O(n)/) an arbitrary element by its index.
ix :: forall n a f. (KnownNat n, Functor f)
   => Finite n -> (a -> f a) -> Vector n a -> f (Vector n a)
ix = V.ix
{-# inline ix #-}

-- | Lens to access (/O(1)/) and update (/O(n)/) the first element of a non-empty vector.
_head :: forall n a f. (KnownNat n, Functor f)
   => (a -> f a) -> Vector (1+n) a -> f (Vector (1+n) a)
_head = V._head
{-# inline _head #-}

-- | Lens to access (/O(1)/) and update (/O(n)/) the last element of a non-empty vector.
_last :: forall n a f. (KnownNat n, Functor f)
      => (a -> f a) -> Vector (n+1) a -> f (Vector (n+1) a)
_last = V._last
{-# inline _last #-}

-- | /O(1)/ Safe indexing in a monad. See the documentation for 'VG.indexM' for
-- an explanation of why this is useful.
indexM :: forall n a m. (KnownNat n, Monad m)
      => Vector n a -> Finite n -> m a
indexM = V.indexM
{-# inline indexM #-}

-- | /O(1)/ Safe indexing in a monad using a 'Proxy'. See the documentation for
-- 'VG.indexM' for an explanation of why this is useful.
indexM' :: forall n k a m p. (KnownNat n, KnownNat k, Monad m)
      => Vector (n+k) a -> p n -> m a
indexM' = V.indexM'
{-# inline indexM' #-}

-- | /O(1)/ Indexing using an Int without bounds checking. See the
-- documentation for 'VG.indexM' for an explanation of why this is useful.
unsafeIndexM :: forall n a m. (KnownNat n, Monad m)
      => Vector n a -> Int -> m a
unsafeIndexM = V.unsafeIndexM
{-# inline unsafeIndexM #-}

-- | /O(1)/ Yield the first element of a non-empty vector in a monad. See the
-- documentation for 'VG.indexM' for an explanation of why this is useful.
headM :: forall n a m. (KnownNat n, Monad m)
      => Vector (1+n) a -> m a
headM = V.headM
{-# inline headM #-}

-- | /O(1)/ Yield the last element of a non-empty vector in a monad. See the
-- documentation for 'VG.indexM' for an explanation of why this is useful.
lastM :: forall n a m. (KnownNat n, Monad m)
      => Vector (n+1) a -> m a
lastM = V.lastM
{-# inline lastM #-}

-- | /O(1)/ Yield a slice of the vector without copying it with an inferred
-- length argument.
slice :: forall i n m a p. (KnownNat i, KnownNat n, KnownNat m)
      => p i -- ^ starting index
      -> Vector (i+n+m) a
      -> Vector n a
slice = V.slice
{-# inline slice #-}

-- | /O(1)/ Yield a slice of the vector without copying it with an explicit
-- length argument.
slice' :: forall i n m a p. (KnownNat i, KnownNat n, KnownNat m)
       => p i -- ^ starting index
       -> p n -- ^ length
       -> Vector (i+n+m) a
       -> Vector n a
slice' = V.slice'
{-# inline slice' #-}

-- | /O(1)/ Yield all but the last element of a non-empty vector without
-- copying.
init :: forall n a. Vector (n+1) a -> Vector n a
init = V.init
{-# inline init #-}

-- | /O(1)/ Yield all but the first element of a non-empty vector without
-- copying.
tail :: forall n a. Vector (1+n) a -> Vector n a
tail = V.tail
{-# inline tail #-}

-- | /O(1)/ Yield the first n elements. The resultant vector always contains
-- this many elements. The length of the resultant vector is inferred from the
-- type.
take :: forall n m a. (KnownNat n, KnownNat m)
     => Vector (n+m) a -> Vector n a
take = V.take
{-# inline take #-}

-- | /O(1)/ Yield the first n elements. The resultant vector always contains
-- this many elements. The length of the resultant vector is given explicitly
-- as a 'Proxy' argument.
take' :: forall n m a p. (KnownNat n, KnownNat m)
      => p n -> Vector (n+m) a -> Vector n a
take' = V.take'
{-# inline take' #-}

-- | /O(1)/ Yield all but the the first n elements. The given vector must
-- contain at least this many elements The length of the resultant vector is
-- inferred from the type.
drop :: forall n m a. (KnownNat n, KnownNat m)
     => Vector (n+m) a -> Vector m a
drop = V.drop
{-# inline drop #-}

-- | /O(1)/ Yield all but the the first n elements. The given vector must
-- contain at least this many elements The length of the resultant vector is
-- givel explicitly as a 'Proxy' argument.
drop' :: forall n m a p. (KnownNat n, KnownNat m)
      => p n -> Vector (n+m) a -> Vector m a
drop' = V.drop'
{-# inline drop' #-}

-- | /O(1)/ Yield the first n elements paired with the remainder without copying.
-- The lengths of the resultant vector are inferred from the type.
splitAt :: forall n m a. (KnownNat n, KnownNat m)
        => Vector (n+m) a -> (Vector n a, Vector m a)
splitAt = V.splitAt
{-# inline splitAt #-}

-- | /O(1)/ Yield the first n elements paired with the remainder without
-- copying.  The length of the first resultant vector is passed explicitly as a
-- 'Proxy' argument.
splitAt' :: forall n m a p. (KnownNat n, KnownNat m)
         => p n -> Vector (n+m) a -> (Vector n a, Vector m a)
splitAt' = V.splitAt'
{-# inline splitAt' #-}

--------------------------------------------------------------------------------
-- * Construction
--------------------------------------------------------------------------------

--
-- ** Initialization
--

-- | /O(1)/ Empty vector.
empty :: forall a. Vector 0 a
empty = V.empty
{-# inline empty #-}

-- | /O(1)/ Vector with exactly one element.
singleton :: forall a. a -> Vector 1 a
singleton = V.singleton
{-# inline singleton #-}

-- | /O(n)/ Construct a vector with the same element in each position where the
-- length is inferred from the type.
replicate :: forall n a. KnownNat n
          => a -> Vector n a
replicate = V.replicate
{-# inline replicate #-}

-- | /O(n)/ Construct a vector with the same element in each position where the
-- length is given explicitly as a 'Proxy' argument.
replicate' :: forall n a p. KnownNat n
           => p n -> a -> Vector n a
replicate' = V.replicate'
{-# inline replicate' #-}

-- | /O(n)/ construct a vector of the given length by applying the function to
-- each index where the length is inferred from the type.
generate :: forall n a. KnownNat n
         => (Finite n -> a) -> Vector n a
generate = V.generate
{-# inline generate #-}

-- | /O(n)/ construct a vector of the given length by applying the function to
-- each index where the length is given explicitly as a 'Proxy' argument.
generate' :: forall n a p. KnownNat n
          => p n -> (Finite n -> a) -> Vector n a
generate' = V.generate'
{-# inline generate' #-}

-- | /O(n)/ Apply function n times to value. Zeroth element is original value.
-- The length is inferred from the type.
iterateN :: forall n a. KnownNat n
         => (a -> a) -> a -> Vector n a
iterateN = V.iterateN
{-# inline iterateN #-}

-- | /O(n)/ Apply function n times to value. Zeroth element is original value.
-- The length is given explicitly as a 'Proxy' argument.
iterateN' :: forall n a p. KnownNat n
          => p n -> (a -> a) -> a -> Vector n a
iterateN' = V.iterateN'
{-# inline iterateN' #-}

--
-- ** Monadic initialisation
--

-- | /O(n)/ Execute the monadic action @n@ times and store the results in a
-- vector where @n@ is inferred from the type.
replicateM :: forall n m a. (KnownNat n, Monad m)
           => m a -> m (Vector n a)
replicateM = V.replicateM
{-# inline replicateM #-}

-- | /O(n)/ Execute the monadic action @n@ times and store the results in a
-- vector where @n@ is given explicitly as a 'Proxy' argument.
replicateM' :: forall n m a p. (KnownNat n, Monad m)
            => p n -> m a -> m (Vector n a)
replicateM' = V.replicateM'
{-# inline replicateM' #-}

-- | /O(n)/ Construct a vector of length @n@ by applying the monadic action to
-- each index where n is inferred from the type.
generateM :: forall n m a. (KnownNat n, Monad m)
          => (Finite n -> m a) -> m (Vector n a)
generateM = V.generateM
{-# inline generateM #-}

-- | /O(n)/ Construct a vector of length @n@ by applying the monadic action to
-- each index where n is given explicitly as a 'Proxy' argument.
generateM' :: forall n m a p. (KnownNat n, Monad m)
           => p n -> (Finite n -> m a) -> m (Vector n a)
generateM' = V.generateM'
{-# inline generateM' #-}

--
-- ** Unfolding
--

-- | /O(n)/ Construct a vector with exactly @n@ elements by repeatedly applying
-- the generator function to the a seed. The length, @n@, is inferred from the
-- type.
unfoldrN :: forall n a b. KnownNat n
         => (b -> (a, b)) -> b -> Vector n a
unfoldrN = V.unfoldrN
{-# inline unfoldrN #-}

-- | /O(n)/ Construct a vector with exactly @n@ elements by repeatedly applying
-- the generator function to the a seed. The length, @n@, is given explicitly
-- as a 'Proxy' argument.
unfoldrN' :: forall n a b p. KnownNat n
          => p n -> (b -> (a, b)) -> b -> Vector n a
unfoldrN' = V.unfoldrN'
{-# inline unfoldrN' #-}

--
-- ** Enumeration
--

-- | /O(n)/ Yield a vector of length @n@ containing the values @x@, @x+1@
-- etc. The length, @n@, is inferred from the type.
enumFromN :: forall n a. (KnownNat n, Num a)
          => a -> Vector n a
enumFromN = V.enumFromN
{-# inline enumFromN #-}

-- | /O(n)/ Yield a vector of length @n@ containing the values @x@, @x+1@
-- etc. The length, @n@, is given explicitly as a 'Proxy' argument.
enumFromN' :: forall n a p. (KnownNat n, Num a)
           => a -> p n -> Vector n a
enumFromN' = V.enumFromN'
{-# inline enumFromN' #-}

-- | /O(n)/ Yield a vector of the given length containing the values @x@, @x+y@,
-- @x+y+y@ etc. The length, @n@, is inferred from the type.
enumFromStepN :: forall n a. (KnownNat n, Num a)
          => a -> a -> Vector n a
enumFromStepN = V.enumFromStepN
{-# inline enumFromStepN #-}

-- | /O(n)/ Yield a vector of the given length containing the values @x@, @x+y@,
-- @x+y+y@ etc. The length, @n@, is given explicitly as a 'Proxy' argument.
enumFromStepN' :: forall n a p. (KnownNat n, Num a)
               => a -> a -> p n -> Vector n a
enumFromStepN' = V.enumFromStepN'
{-# inline enumFromStepN' #-}

--
-- ** Concatenation
--

-- | /O(n)/ Prepend an element.
cons :: forall n a. a -> Vector n a -> Vector (1+n) a
cons = V.cons
{-# inline cons #-}

-- | /O(n)/ Append an element.
snoc :: forall n a. Vector n a -> a -> Vector (n+1) a
snoc = V.snoc
{-# inline snoc #-}

-- | /O(m+n)/ Concatenate two vectors.
(++) :: forall n m a. Vector n a -> Vector m a -> Vector (n+m) a
(++) = (V.++)
{-# inline (++) #-}

--
-- ** Restricting memory usage
--

-- | /O(n)/ Yield the argument but force it not to retain any extra memory,
-- possibly by copying it.
--
-- This is especially useful when dealing with slices. For example:
--
-- > force (slice 0 2 <huge vector>)
--
-- Here, the slice retains a reference to the huge vector. Forcing it creates
-- a copy of just the elements that belong to the slice and allows the huge
-- vector to be garbage collected.
force :: Vector n a -> Vector n a
force = V.force
{-# inline force #-}


--------------------------------------------------------------------------------
-- * Modifying vectors
--------------------------------------------------------------------------------

--
-- ** Bulk updates
--

-- | /O(m+n)/ For each pair @(i,a)@ from the list, replace the vector
-- element at position @i@ by @a@.
--
-- > <5,9,2,7> // [(2,1),(0,3),(2,8)] = <3,9,8,7>
--
(//) :: Vector m a -- ^ initial vector (of length @m@)
     -> [(Int, a)]   -- ^ list of index/value pairs (of length @n@)
     -> Vector m a
(//) = (V.//)
{-# inline (//) #-}

-- | /O(m+n)/ For each pair @(i,a)@ from the vector of index/value pairs,
-- replace the vector element at position @i@ by @a@.
--
-- > update <5,9,2,7> <(2,1),(0,3),(2,8)> = <3,9,8,7>
--
update :: Vector m a        -- ^ initial vector (of length @m@)
       -> Vector n (Int, a) -- ^ vector of index/value pairs (of length @n@)
       -> Vector m a
update = V.update
{-# inline update #-}

-- | /O(m+n)/ For each index @i@ from the index vector and the
-- corresponding value @a@ from the value vector, replace the element of the
-- initial vector at position @i@ by @a@.
--
-- > update_ <5,9,2,7>  <2,0,2> <1,3,8> = <3,9,8,7>
--
-- This function is useful for instances of 'Vector' that cannot store pairs.
-- Otherwise, 'update' is probably more convenient.
--
-- @
-- update_ xs is ys = 'update' xs ('zip' is ys)
-- @
update_ :: Vector m a   -- ^ initial vector (of length @m@)
        -> Vector n Int -- ^ index vector (of length @n@)
        -> Vector n a   -- ^ value vector (of length @n@)
        -> Vector m a
update_ = V.update_
{-# inline update_ #-}

-- | Same as ('//') but without bounds checking.
unsafeUpd :: Vector m a -- ^ initial vector (of length @m@)
          -> [(Int, a)]   -- ^ list of index/value pairs (of length @n@)
          -> Vector m a
unsafeUpd = V.unsafeUpd
{-# inline unsafeUpd #-}

-- | Same as 'update' but without bounds checking.
unsafeUpdate :: Vector m a        -- ^ initial vector (of length @m@)
             -> Vector n (Int, a) -- ^ vector of index/value pairs (of length @n@)
             -> Vector m a
unsafeUpdate = V.unsafeUpdate
{-# inline unsafeUpdate #-}

-- | Same as 'update_' but without bounds checking.
unsafeUpdate_ :: Vector m a   -- ^ initial vector (of length @m@)
              -> Vector n Int -- ^ index vector (of length @n@)
              -> Vector n a   -- ^ value vector (of length @n@)
              -> Vector m a
unsafeUpdate_ = V.unsafeUpdate_
{-# inline unsafeUpdate_ #-}

--
-- ** Accumulations
--

-- | /O(m+n)/ For each pair @(i,b)@ from the list, replace the vector element
-- @a@ at position @i@ by @f a b@.
--
-- > accum (+) <5,9,2> [(2,4),(1,6),(0,3),(1,7)] = <5+3, 9+6+7, 2+4>
accum :: (a -> b -> a) -- ^ accumulating function @f@
      -> Vector m a  -- ^ initial vector (of length @m@)
      -> [(Int,b)]     -- ^ list of index/value pairs (of length @n@)
      -> Vector m a
accum = V.accum
{-# inline accum #-}

-- | /O(m+n)/ For each pair @(i,b)@ from the vector of pairs, replace the vector
-- element @a@ at position @i@ by @f a b@.
--
-- > accumulate (+) <5,9,2> <(2,4),(1,6),(0,3),(1,7)> = <5+3, 9+6+7, 2+4>
accumulate :: (a -> b -> a)      -- ^ accumulating function @f@
           -> Vector m a       -- ^ initial vector (of length @m@)
           -> Vector n (Int,b) -- ^ vector of index/value pairs (of length @n@)
           -> Vector m a
accumulate = V.accumulate
{-# inline accumulate #-}

-- | /O(m+n)/ For each index @i@ from the index vector and the
-- corresponding value @b@ from the the value vector,
-- replace the element of the initial vector at
-- position @i@ by @f a b@.
--
-- > accumulate_ (+) <5,9,2> <2,1,0,1> <4,6,3,7> = <5+3, 9+6+7, 2+4>
--
-- This function is useful for instances of 'Vector' that cannot store pairs.
-- Otherwise, 'accumulate' is probably more convenient:
--
-- @
-- accumulate_ f as is bs = 'accumulate' f as ('zip' is bs)
-- @
accumulate_ :: (a -> b -> a)  -- ^ accumulating function @f@
            -> Vector m a   -- ^ initial vector (of length @m@)
            -> Vector n Int -- ^ index vector (of length @n@)
            -> Vector n b   -- ^ value vector (of length @n@)
            -> Vector m a
accumulate_ = V.accumulate_
{-# inline accumulate_ #-}

-- | Same as 'accum' but without bounds checking.
unsafeAccum :: (a -> b -> a) -- ^ accumulating function @f@
            -> Vector m a  -- ^ initial vector (of length @m@)
            -> [(Int,b)]     -- ^ list of index/value pairs (of length @n@)
            -> Vector m a
unsafeAccum = V.unsafeAccum
{-# inline unsafeAccum #-}

-- | Same as 'accumulate' but without bounds checking.
unsafeAccumulate :: (a -> b -> a)      -- ^ accumulating function @f@
                 -> Vector m a       -- ^ initial vector (of length @m@)
                 -> Vector n (Int,b) -- ^ vector of index/value pairs (of length @n@)
                 -> Vector m a
unsafeAccumulate = V.unsafeAccumulate
{-# inline unsafeAccumulate #-}

-- | Same as 'accumulate_' but without bounds checking.
unsafeAccumulate_ :: (a -> b -> a)  -- ^ accumulating function @f@
                  -> Vector m a   -- ^ initial vector (of length @m@)
                  -> Vector n Int -- ^ index vector (of length @n@)
                  -> Vector n b   -- ^ value vector (of length @n@)
                  -> Vector m a
unsafeAccumulate_ = V.unsafeAccumulate_
{-# inline unsafeAccumulate_ #-}

--
-- ** Permutations
--

-- | /O(n)/ Reverse a vector
reverse ::  Vector n a -> Vector n a
reverse = V.reverse
{-# inline reverse #-}

-- | /O(n)/ Yield the vector obtained by replacing each element @i@ of the
-- index vector by @xs'!'i@. This is equivalent to @'map' (xs'!') is@ but is
-- often much more efficient.
--
-- > backpermute <a,b,c,d> <0,3,2,3,1,0> = <a,d,c,d,b,a>
backpermute :: Vector m a   -- ^ @xs@ value vector
            -> Vector n Int -- ^ @is@ index vector (of length @n@)
            -> Vector n a
backpermute = V.backpermute
{-# inline backpermute #-}

-- | Same as 'backpermute' but without bounds checking.
unsafeBackpermute :: Vector m a   -- ^ @xs@ value vector
                  -> Vector n Int -- ^ @is@ index vector (of length @n@)
                  -> Vector n a
unsafeBackpermute = V.unsafeBackpermute
{-# inline unsafeBackpermute #-}

--------------------------------------------------------------------------------
-- * Elementwise Operations
--------------------------------------------------------------------------------

--
-- ** Indexing
--

-- | /O(n)/ Pair each element in a vector with its index
indexed :: Vector n a -> Vector n (Int,a)
indexed = V.indexed
{-# inline indexed #-}

--
-- ** Mapping
--

-- | /O(n)/ Map a function over a vector
map :: (a -> b) -> Vector n a -> Vector n b
map = V.map
{-# inline map #-}

-- | /O(n)/ Apply a function to every element of a vector and its index
imap :: (Finite n -> a -> b) -> Vector n a -> Vector n b
imap = V.imap
{-# inline imap #-}

-- | /O(n*m)/ Map a function over a vector and concatenate the results. The
-- function is required to always return the same length vector.
concatMap :: (a -> Vector m b) -> Vector n a -> Vector (n*m) b
concatMap = V.concatMap
{-# inline concatMap #-}

--
-- ** Monadic mapping
--

-- | /O(n)/ Apply the monadic action to all elements of the vector, yielding a
-- vector of results
mapM :: Monad m => (a -> m b) -> Vector n a -> m (Vector n b)
mapM = V.mapM
{-# inline mapM #-}

-- | /O(n)/ Apply the monadic action to every element of a vector and its
-- index, yielding a vector of results
imapM :: Monad m => (Finite n -> a -> m b) -> Vector n a -> m (Vector n b)
imapM = V.imapM
{-# inline imapM #-}

-- | /O(n)/ Apply the monadic action to all elements of a vector and ignore the
-- results
mapM_ :: Monad m => (a -> m b) -> Vector n a -> m ()
mapM_ = V.mapM_
{-# inline mapM_ #-}

-- | /O(n)/ Apply the monadic action to every element of a vector and its
-- index, ignoring the results
imapM_ :: Monad m => (Finite n -> a -> m b) -> Vector n a -> m ()
imapM_ = V.imapM_
{-# inline imapM_ #-}

-- | /O(n)/ Apply the monadic action to all elements of the vector, yielding a
-- vector of results. Equvalent to @flip 'mapM'@.
forM :: Monad m => Vector n a -> (a -> m b) -> m (Vector n b)
forM = V.forM
{-# inline forM #-}

-- | /O(n)/ Apply the monadic action to all elements of a vector and ignore the
-- results. Equivalent to @flip 'mapM_'@.
forM_ :: Monad m => Vector n a -> (a -> m b) -> m ()
forM_ = V.forM_
{-# inline forM_ #-}

--
-- ** Zipping
--

-- | /O(n)/ Zip two vectors of the same length with the given function.
zipWith :: (a -> b -> c) -> Vector n a -> Vector n b -> Vector n c
zipWith = V.zipWith
{-# inline zipWith #-}

-- | Zip three vectors with the given function.
zipWith3 :: (a -> b -> c -> d) -> Vector n a -> Vector n b -> Vector n c -> Vector n d
zipWith3 = V.zipWith3
{-# inline zipWith3 #-}

zipWith4 :: (a -> b -> c -> d -> e)
         -> Vector n a
         -> Vector n b
         -> Vector n c
         -> Vector n d
         -> Vector n e
zipWith4 = V.zipWith4
{-# inline zipWith4 #-}

zipWith5 :: (a -> b -> c -> d -> e -> f)
         -> Vector n a
         -> Vector n b
         -> Vector n c
         -> Vector n d
         -> Vector n e
         -> Vector n f
zipWith5 = V.zipWith5
{-# inline zipWith5 #-}

zipWith6 :: (a -> b -> c -> d -> e -> f -> g)
         -> Vector n a
         -> Vector n b
         -> Vector n c
         -> Vector n d
         -> Vector n e
         -> Vector n f
         -> Vector n g
zipWith6 = V.zipWith6
{-# inline zipWith6 #-}

-- | /O(n)/ Zip two vectors of the same length with a function that also takes
-- the elements' indices).
izipWith :: (Finite n -> a -> b -> c)
         -> Vector n a
         -> Vector n b
         -> Vector n c
izipWith = V.izipWith
{-# inline izipWith #-}

izipWith3 :: (Finite n -> a -> b -> c -> d)
          -> Vector n a
          -> Vector n b
          -> Vector n c
          -> Vector n d
izipWith3 = V.izipWith3
{-# inline izipWith3 #-}

izipWith4 :: (Finite n -> a -> b -> c -> d -> e)
          -> Vector n a
          -> Vector n b
          -> Vector n c
          -> Vector n d
          -> Vector n e
izipWith4 = V.izipWith4
{-# inline izipWith4 #-}

izipWith5 :: (Finite n -> a -> b -> c -> d -> e -> f)
          -> Vector n a
          -> Vector n b
          -> Vector n c
          -> Vector n d
          -> Vector n e
          -> Vector n f
izipWith5 = V.izipWith5
{-# inline izipWith5 #-}

izipWith6 :: (Finite n -> a -> b -> c -> d -> e -> f -> g)
          -> Vector n a
          -> Vector n b
          -> Vector n c
          -> Vector n d
          -> Vector n e
          -> Vector n f
          -> Vector n g
izipWith6 = V.izipWith6
{-# inline izipWith6 #-}

-- | /O(n)/ Zip two vectors of the same length
zip :: Vector n a -> Vector n b -> Vector n (a, b)
zip = V.zip
{-# inline zip #-}

zip3 :: Vector n a -> Vector n b -> Vector n c -> Vector n (a, b, c)
zip3 = V.zip3
{-# inline zip3 #-}

zip4 :: Vector n a
     -> Vector n b
     -> Vector n c
     -> Vector n d
     -> Vector n (a,b,c,d)
zip4 = V.zip4
{-# inline zip4 #-}

zip5 :: Vector n a
     -> Vector n b
     -> Vector n c
     -> Vector n d
     -> Vector n e
     -> Vector n (a,b,c,d,e)
zip5 = V.zip5
{-# inline zip5 #-}

zip6 :: Vector n a
     -> Vector n b
     -> Vector n c
     -> Vector n d
     -> Vector n e
     -> Vector n f
     -> Vector n (a,b,c,d,e,f)
zip6 = V.zip6
{-# inline zip6 #-}

--
-- ** Monadic zipping
--

-- | /O(n)/ Zip the two vectors of the same length with the monadic action and
-- yield a vector of results
zipWithM :: Monad m
         => (a -> b -> m c) -> Vector n a -> Vector n b -> m (Vector n c)
zipWithM = V.zipWithM
{-# inline zipWithM #-}

-- | /O(n)/ Zip the two vectors with a monadic action that also takes the
-- element index and yield a vector of results
izipWithM :: Monad m
         => (Finite n -> a -> b -> m c) -> Vector n a -> Vector n b -> m (Vector n c)
izipWithM = V.izipWithM
{-# inline izipWithM #-}

-- | /O(n)/ Zip the two vectors with the monadic action and ignore the results
zipWithM_ :: Monad m
          => (a -> b -> m c) -> Vector n a -> Vector n b -> m ()
zipWithM_ = V.zipWithM_
{-# inline zipWithM_ #-}

-- | /O(n)/ Zip the two vectors with a monadic action that also takes
-- the element index and ignore the results
izipWithM_ :: Monad m
           => (Finite n -> a -> b -> m c) -> Vector n a -> Vector n b -> m ()
izipWithM_ = V.izipWithM_
{-# inline izipWithM_ #-}

-- Unzipping
-- ---------

-- | /O(min(m,n))/ Unzip a vector of pairs.
unzip :: Vector n (a, b) -> (Vector n a, Vector n b)
unzip = V.unzip
{-# inline unzip #-}

unzip3 :: Vector n (a, b, c) -> (Vector n a, Vector n b, Vector n c)
unzip3 = V.unzip3
{-# inline unzip3 #-}

unzip4 :: Vector n (a, b, c, d) -> (Vector n a, Vector n b, Vector n c, Vector n d)
unzip4 = V.unzip4
{-# inline unzip4 #-}

unzip5 :: Vector n (a, b, c, d, e) -> (Vector n a, Vector n b, Vector n c, Vector n d, Vector n e)
unzip5 = V.unzip5
{-# inline unzip5 #-}

unzip6 :: Vector n (a, b, c, d, e, f) -> (Vector n a, Vector n b, Vector n c, Vector n d, Vector n e, Vector n f)
unzip6 = V.unzip6
{-# inline unzip6 #-}

--------------------------------------------------------------------------------
-- * Working with predicates
--------------------------------------------------------------------------------

--
-- ** Searching
--


infix 4 `elem`
-- | /O(n)/ Check if the vector contains an element
elem :: Eq a => a -> Vector n a -> Bool
elem = V.elem
{-# inline elem #-}

infix 4 `notElem`
-- | /O(n)/ Check if the vector does not contain an element (inverse of 'elem')
notElem :: Eq a => a -> Vector n a -> Bool
notElem = V.notElem
{-# inline notElem #-}

-- | /O(n)/ Yield 'Just' the first element matching the predicate or 'Nothing'
-- if no such element exists.
find :: (a -> Bool) -> Vector n a -> Maybe a
find = V.find
{-# inline find #-}

-- | /O(n)/ Yield 'Just' the index of the first element matching the predicate
-- or 'Nothing' if no such element exists.
findIndex :: (a -> Bool) -> Vector n a -> Maybe (Finite n)
findIndex = V.findIndex
{-# inline findIndex #-}

-- | /O(n)/ Yield 'Just' the index of the first occurence of the given element or
-- 'Nothing' if the vector does not contain the element. This is a specialised
-- version of 'findIndex'.
elemIndex :: (Eq a) => a -> Vector n a -> Maybe (Finite n)
elemIndex = V.elemIndex
{-# inline elemIndex #-}

--------------------------------------------------------------------------------
-- * Folding
--------------------------------------------------------------------------------

-- | /O(n)/ Left fold
foldl :: (a -> b -> a) -> a -> Vector n b -> a
foldl = V.foldl
{-# inline foldl #-}

-- | /O(n)/ Left fold on non-empty vectors
foldl1 :: KnownNat n => (a -> a -> a) -> Vector (1+n) a -> a
foldl1 = V.foldl1
{-# inline foldl1 #-}

-- | /O(n)/ Left fold with strict accumulator
foldl' :: (a -> b -> a) -> a -> Vector n b -> a
foldl' = V.foldl'
{-# inline foldl' #-}

-- | /O(n)/ Left fold on non-empty vectors with strict accumulator
foldl1' :: KnownNat n => (a -> a -> a) -> Vector (1+n) a -> a
foldl1' = V.foldl1'
{-# inline foldl1' #-}

-- | /O(n)/ Right fold
foldr :: (a -> b -> b) -> b -> Vector n a -> b
foldr = V.foldr
{-# inline foldr #-}

-- | /O(n)/ Right fold on non-empty vectors
foldr1 :: KnownNat n => (a -> a -> a) -> Vector (n+1) a -> a
foldr1 = V.foldr1
{-# inline foldr1 #-}

-- | /O(n)/ Right fold with a strict accumulator
foldr' :: (a -> b -> b) -> b -> Vector n a -> b
foldr' = V.foldr'
{-# inline foldr' #-}

-- | /O(n)/ Right fold on non-empty vectors with strict accumulator
foldr1' :: KnownNat n => (a -> a -> a) -> Vector (n+1) a -> a
foldr1' = V.foldr1'
{-# inline foldr1' #-}

-- | /O(n)/ Left fold (function applied to each element and its index)
ifoldl :: (a -> Finite n -> b -> a) -> a -> Vector n b -> a
ifoldl = V.ifoldl
{-# inline ifoldl #-}

-- | /O(n)/ Left fold with strict accumulator (function applied to each element
-- and its index)
ifoldl' :: (a -> Finite n -> b -> a) -> a -> Vector n b -> a
ifoldl' = V.ifoldl'
{-# inline ifoldl' #-}

-- | /O(n)/ Right fold (function applied to each element and its index)
ifoldr :: (Finite n -> a -> b -> b) -> b -> Vector n a -> b
ifoldr = V.ifoldr
{-# inline ifoldr #-}

-- | /O(n)/ Right fold with strict accumulator (function applied to each
-- element and its index)
ifoldr' :: (Finite n -> a -> b -> b) -> b -> Vector n a -> b
ifoldr' = V.ifoldr'
{-# inline ifoldr' #-}

-- ** Specialised folds

-- | /O(n)/ Check if all elements satisfy the predicate.
all :: (a -> Bool) -> Vector n a -> Bool
all = V.all
{-# inline all #-}

-- | /O(n)/ Check if any element satisfies the predicate.
any :: (a -> Bool) -> Vector n a -> Bool
any = V.any
{-# inline any #-}

-- | /O(n)/ Check if all elements are 'True'
and :: Vector n Bool -> Bool
and = V.and
{-# inline and #-}

-- | /O(n)/ Check if any element is 'True'
or :: Vector n Bool -> Bool
or = V.or
{-# inline or #-}

-- | /O(n)/ Compute the sum of the elements
sum :: (Num a) => Vector n a -> a
sum = V.sum
{-# inline sum #-}

-- | /O(n)/ Compute the produce of the elements
product :: (Num a) => Vector n a -> a
product = V.product
{-# inline product #-}

-- | /O(n)/ Yield the maximum element of the non-empty vector.
maximum :: (Ord a, KnownNat n) => Vector (n+1) a -> a
maximum = V.maximum
{-# inline maximum #-}

-- | /O(n)/ Yield the maximum element of the non-empty vector according to the
-- given comparison function.
maximumBy :: KnownNat n
          => (a -> a -> Ordering) -> Vector (n+1) a -> a
maximumBy = V.maximumBy
{-# inline maximumBy #-}

-- | /O(n)/ Yield the minimum element of the non-empty vector.
minimum :: (Ord a, KnownNat n) => Vector (n+1) a -> a
minimum = V.minimum
{-# inline minimum #-}

-- | /O(n)/ Yield the minimum element of the non-empty vector according to the
-- given comparison function.
minimumBy :: KnownNat n
          => (a -> a -> Ordering) -> Vector (n+1) a -> a
minimumBy = V.minimumBy
{-# inline minimumBy #-}

-- | /O(n)/ Yield the index of the maximum element of the non-empty vector.
maxIndex :: (Ord a, KnownNat n) => Vector (n+1) a -> Finite (n + 1)
maxIndex = V.maxIndex
{-# inline maxIndex #-}

-- | /O(n)/ Yield the index of the maximum element of the non-empty vector
-- according to the given comparison function.
maxIndexBy :: KnownNat n
           => (a -> a -> Ordering) -> Vector (n+1) a -> Finite (n + 1)
maxIndexBy = V.maxIndexBy
{-# inline maxIndexBy #-}

-- | /O(n)/ Yield the index of the minimum element of the non-empty vector.
minIndex :: (Ord a, KnownNat n) => Vector (n+1) a -> Finite (n + 1)
minIndex = V.minIndex
{-# inline minIndex #-}

-- | /O(n)/ Yield the index of the minimum element of the non-empty vector
-- according to the given comparison function.
minIndexBy :: KnownNat n
           => (a -> a -> Ordering) -> Vector (n+1) a -> Finite (n + 1)
minIndexBy = V.minIndexBy
{-# inline minIndexBy #-}

-- ** Monadic folds

-- | /O(n)/ Monadic fold
foldM :: Monad m => (a -> b -> m a) -> a -> Vector n b -> m a
foldM = V.foldM
{-# inline foldM #-}

-- | /O(n)/ Monadic fold (action applied to each element and its index)
ifoldM :: Monad m => (a -> Finite n -> b -> m a) -> a -> Vector n b -> m a
ifoldM = V.ifoldM
{-# inline ifoldM #-}

-- | /O(n)/ Monadic fold over non-empty vectors
fold1M :: (Monad m, KnownNat n)
       => (a -> a -> m a) -> Vector (1+n) a -> m a
fold1M = V.fold1M
{-# inline fold1M #-}

-- | /O(n)/ Monadic fold with strict accumulator
foldM' :: Monad m => (a -> b -> m a) -> a -> Vector n b -> m a
foldM' = V.foldM'
{-# inline foldM' #-}

-- | /O(n)/ Monadic fold with strict accumulator (action applied to each
-- element and its index)
ifoldM' :: Monad m
        => (a -> Finite n -> b -> m a) -> a -> Vector n b -> m a
ifoldM' = V.ifoldM'
{-# inline ifoldM' #-}

-- | /O(n)/ Monadic fold over non-empty vectors with strict accumulator
fold1M' :: (Monad m, KnownNat n)
        => (a -> a -> m a) -> Vector (n+1) a -> m a
fold1M' = V.fold1M'
{-# inline fold1M' #-}

-- | /O(n)/ Monadic fold that discards the result
foldM_ :: Monad m
       => (a -> b -> m a) -> a -> Vector n b -> m ()
foldM_ = V.foldM_
{-# inline foldM_ #-}

-- | /O(n)/ Monadic fold that discards the result (action applied to
-- each element and its index)
ifoldM_ :: Monad m
        => (a -> Finite n -> b -> m a) -> a -> Vector n b -> m ()
ifoldM_ = V.ifoldM_
{-# inline ifoldM_ #-}

-- | /O(n)/ Monadic fold over non-empty vectors that discards the result
fold1M_ :: (Monad m, KnownNat n)
        => (a -> a -> m a) -> Vector (n+1) a -> m ()
fold1M_ = V.fold1M_
{-# inline fold1M_ #-}

-- | /O(n)/ Monadic fold with strict accumulator that discards the result
foldM'_ :: Monad m
        => (a -> b -> m a) -> a -> Vector n b -> m ()
foldM'_ = V.foldM'_
{-# inline foldM'_ #-}

-- | /O(n)/ Monadic fold with strict accumulator that discards the result
-- (action applied to each element and its index)
ifoldM'_ :: Monad m
         => (a -> Finite n -> b -> m a) -> a -> Vector n b -> m ()
ifoldM'_ = V.ifoldM'_
{-# inline ifoldM'_ #-}

-- | /O(n)/ Monad fold over non-empty vectors with strict accumulator
-- that discards the result
fold1M'_ :: (Monad m, KnownNat n)
         => (a -> a -> m a) -> Vector (n+1) a -> m ()
fold1M'_ = V.fold1M'_
{-# inline fold1M'_ #-}

-- ** Monadic sequencing

-- | Evaluate each action and collect the results
sequence :: Monad m => Vector n (m a) -> m (Vector n a)
sequence = V.sequence
{-# inline sequence #-}

-- | Evaluate each action and discard the results
sequence_ :: Monad m => Vector n (m a) -> m ()
sequence_ = V.sequence_
{-# inline sequence_ #-}

--------------------------------------------------------------------------------
-- * Prefix sums (scans)
--------------------------------------------------------------------------------

-- | /O(n)/ Prescan
--
-- @
-- prescanl f z = 'init' . 'scanl' f z
-- @
--
-- Example: @prescanl (+) 0 \<1,2,3,4\> = \<0,1,3,6\>@
--
prescanl ::  (a -> b -> a) -> a -> Vector n b -> Vector n a
prescanl = V.prescanl
{-# inline prescanl #-}

-- | /O(n)/ Prescan with strict accumulator
prescanl' ::  (a -> b -> a) -> a -> Vector n b -> Vector n a
prescanl' = V.prescanl'
{-# inline prescanl' #-}

-- | /O(n)/ Scan
postscanl ::  (a -> b -> a) -> a -> Vector n b -> Vector n a
postscanl = V.postscanl
{-# inline postscanl #-}

-- | /O(n)/ Scan with strict accumulator
postscanl' ::  (a -> b -> a) -> a -> Vector n b -> Vector n a
postscanl' = V.postscanl'
{-# inline postscanl' #-}

-- | /O(n)/ Haskell-style scan
scanl ::  (a -> b -> a) -> a -> Vector n b -> Vector n a
scanl = V.scanl
{-# inline scanl #-}

-- | /O(n)/ Haskell-style scan with strict accumulator
scanl' ::  (a -> b -> a) -> a -> Vector n b -> Vector n a
scanl' = V.scanl'
{-# inline scanl' #-}

-- | /O(n)/ Scan over a non-empty vector
scanl1 :: KnownNat n => (a -> a -> a) -> Vector (n+1) a -> Vector (n+1) a
scanl1 = V.scanl1
{-# inline scanl1 #-}

-- | /O(n)/ Scan over a non-empty vector with a strict accumulator
scanl1' :: KnownNat n => (a -> a -> a) -> Vector (n+1) a -> Vector (n+1) a
scanl1' = V.scanl1'
{-# inline scanl1' #-}

-- | /O(n)/ Right-to-left prescan
prescanr ::  (a -> b -> b) -> b -> Vector n a -> Vector n b
prescanr = V.prescanr
{-# inline prescanr #-}

-- | /O(n)/ Right-to-left prescan with strict accumulator
prescanr' ::  (a -> b -> b) -> b -> Vector n a -> Vector n b
prescanr' = V.prescanr'
{-# inline prescanr' #-}

-- | /O(n)/ Right-to-left scan
postscanr ::  (a -> b -> b) -> b -> Vector n a -> Vector n b
postscanr = V.postscanr
{-# inline postscanr #-}

-- | /O(n)/ Right-to-left scan with strict accumulator
postscanr' ::  (a -> b -> b) -> b -> Vector n a -> Vector n b
postscanr' = V.postscanr'
{-# inline postscanr' #-}

-- | /O(n)/ Right-to-left Haskell-style scan
scanr ::  (a -> b -> b) -> b -> Vector n a -> Vector n b
scanr = V.scanr
{-# inline scanr #-}

-- | /O(n)/ Right-to-left Haskell-style scan with strict accumulator
scanr' ::  (a -> b -> b) -> b -> Vector n a -> Vector n b
scanr' = V.scanr'
{-# inline scanr' #-}

-- | /O(n)/ Right-to-left scan over a non-empty vector
scanr1 :: KnownNat n => (a -> a -> a) -> Vector (n+1) a -> Vector (n+1) a
scanr1 = V.scanr1
{-# inline scanr1 #-}

-- | /O(n)/ Right-to-left scan over a non-empty vector with a strict
-- accumulator
scanr1' :: KnownNat n => (a -> a -> a) -> Vector (n+1) a -> Vector (n+1) a
scanr1' = V.scanr1'
{-# inline scanr1' #-}


-- * Conversions

-- ** Lists

-- | /O(n)/ Convert a vector to a list
toList :: Vector n a -> [a]
toList = V.toList
{-# inline toList #-}

-- | /O(n)/ Convert a list to a vector
fromList :: KnownNat n => [a] -> Maybe (Vector n a)
fromList = V.fromList
{-# inline fromList #-}

-- | /O(n)/ Convert the first @n@ elements of a list to a vector. The length of
-- the resultant vector is inferred from the type.
fromListN :: forall n a. KnownNat n
          => [a] -> Maybe (Vector n a)
fromListN = V.fromListN
{-# inline fromListN #-}

-- | /O(n)/ Convert the first @n@ elements of a list to a vector. The length of
-- the resultant vector is given explicitly as a 'Proxy' argument.
fromListN' :: forall n a p. KnownNat n
           => p n -> [a] -> Maybe (Vector n a)
fromListN' = V.fromListN'
{-# inline fromListN' #-}

-- | /O(n)/ Takes a list and returns a continuation providing a vector with
-- a size parameter corresponding to the length of the list.
--
-- Essentially converts a list into a vector with the proper size
-- parameter, determined at runtime.
--
-- See 'withSized'
withSizedList :: forall a r. [a] -> (forall n. KnownNat n => Vector n a -> r) -> r
withSizedList xs = withSized (VU.fromList xs)
{-# inline withSizedList #-}

-- ** Mutable vectors

-- | /O(n)/ Yield an immutable copy of the mutable vector.
freeze :: PrimMonad m
       => VM.MVector n (PrimState m) a
       -> m (Vector n a)
freeze = V.freeze

-- | /O(1)/ Unsafely convert a mutable vector to an immutable one withouy
-- copying. The mutable vector may not be used after this operation.
unsafeFreeze :: PrimMonad m
             => VM.MVector n (PrimState m) a
             -> m (Vector n a)
unsafeFreeze = V.unsafeFreeze

-- | /O(n)/ Yield a mutable copy of the immutable vector.
thaw :: PrimMonad m
     => Vector n a
     -> m (VM.MVector n (PrimState m) a)
thaw = V.thaw

-- | /O(n)/ Unsafely convert an immutable vector to a mutable one without
-- copying. The immutable vector may not be used after this operation.
unsafeThaw :: PrimMonad m
           => Vector n a
           -> m (VM.MVector n (PrimState m) a)
unsafeThaw = V.unsafeThaw

-- | /O(n)/ Copy an immutable vector into a mutable one.
copy :: PrimMonad m
     => VM.MVector n (PrimState m) a
     -> Vector n a
     -> m ()
copy = V.copy

-- ** Unsized vectors

-- | Convert a 'Data.Vector.Generic.Vector' into a
-- 'Data.Vector.Generic.Sized.Vector' if it has the correct size, otherwise
-- return Nothing.
toSized :: forall n a. KnownNat n
        => VU.Vector a -> Maybe (Vector n a)
toSized = V.toSized
{-# inline toSized #-}

-- | Takes a 'Data.Vector.Vector' and returns a continuation providing
-- a 'Data.Vector.Sized.Vector' with a size parameter @n@ that is
-- determined at runtime based on the length of the input vector.
--
-- Essentially converts a 'Data.Vector.Vector' into
-- a 'Data.Vector.Sized.Vector' with the correct size parameter
-- @n@.
withSized :: forall a r. VU.Vector a -> (forall n. KnownNat n => Vector n a -> r) -> r
withSized = V.withSized
{-# inline withSized #-}

fromSized :: Vector n a -> VU.Vector a
fromSized = V.fromSized
{-# inline fromSized #-}

-- | Apply a function on unsized vectors to a sized vector. The function must
-- preserve the size of the vector, this is not checked.
withVectorUnsafe :: (VU.Vector a -> VU.Vector b) -> Vector n a -> Vector n b
withVectorUnsafe = V.withVectorUnsafe
{-# inline withVectorUnsafe #-}

