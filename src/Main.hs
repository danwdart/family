{-# OPTIONS_GHC -Wno-unused-matches #-}

import Data.Gedcom
import Data.Gedcom.Internal.CoreTypes
import qualified Data.Text as T

main :: IO ()
main = do
    Right (gedcom, xref) <- parseGedcomFile "familytree.ged"
    let firstPerson = (\(GDStructure a) -> a) $ head $ gedcomIndividual gedcom
    let firstPersonName = (\(Name a b) -> a) $ personalNameName $ (\(Just a) -> a) $ individualName $ firstPerson
    let number = length $ gedcomIndividual gedcom
    putStrLn $ "First person named: " <> T.unpack firstPerson
    putStrLn $ "Number of individuals: " <> show number
    pure ()