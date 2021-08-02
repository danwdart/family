{-# OPTIONS_GHC -Wno-unused-matches #-}

-- import Data.Either
import Data.Gedcom
import qualified Data.Text as T

main :: IO ()
main = do
    Right (gedcom, xref) <- parseGedcomFile "familytree.ged"
    let firstPerson = (\(Right a) -> a) $ flip gdLookup xref $ head $ gedcomIndividual gedcom
    -- let family = rights $ flip gdLookup xref <$> gedcomFamily gedcom
    let personsName = (\(Name a b) -> a) . personalNameName . (\(Just a) -> a) . individualName
    let firstPersonName = personsName firstPerson
    let number = length $ gedcomIndividual gedcom
    putStrLn $ "First person named: " <> T.unpack firstPersonName
    putStrLn $ "Number of individuals: " <> show number
    pure ()