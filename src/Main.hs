{-# OPTIONS_GHC -Wno-unused-matches #-}

import Data.Gedcom
import Data.Gedcom.Internal.CoreTypes
import qualified Data.Text as T

data Known a = Never | Unknown | Known a deriving (Eq, Show)

data Person = Person {
    name :: Text,
    born :: Maybe UTCTime,
    died :: Known UTCTime,
    location :: Text,
    occupation :: Text
} deriving (Eq, Show)

-- Tree type?
data Pedigree = Pedigree {
    person :: Person,
    mother :: Maybe Pedigree,
    father :: Maybe Pedigree
} deriving (Eq, Show)

gedcomToPedigree :: Gedcom -> Pedigree
gedcomToPedigree = undefined

main :: IO ()
main = do
    Right (gedcom, xref) <- parseGedcomFile "familytree.ged"
    let firstPerson = (\(GDStructure a) -> a) $ head $ gedcomIndividual gedcom
    let firstPersonName = (\(Name a b) -> a) $ personalNameName $ (\(Just a) -> a) $ individualName $ firstPerson
    let number = length $ gedcomIndividual gedcom
    putStrLn $ "First person named: " <> T.unpack firstPerson
    putStrLn $ "Number of individuals: " <> show number
    pure ()