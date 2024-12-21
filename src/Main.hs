{-# OPTIONS_GHC -Wno-unused-matches -Wno-x-partial #-}

module Main (main) where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Trans.Except
import Data.Gedcom
import Data.Gedcom.Structure
import Data.Maybe
import Data.Text                  qualified as T

main ∷ IO ()
main = do
    result <- parseGedcomFile "familytree.ged"
    case result of
        Right (gedcom, xref) -> void . runExceptT $ do
            firstPerson <- except . flip gdLookup xref . head $ gedcomIndividual gedcom
            -- let family = rights $ flip gdLookup xref <$> gedcomFamily gedcom
            let personsName = (\(Name a b) -> a) . personalNameName . fromJust . individualName
            let firstPersonName = personsName firstPerson
            let number = length $ gedcomIndividual gedcom
            liftIO . putStrLn $ "First person named: " <> T.unpack firstPersonName
            liftIO . putStrLn $ "Number of individuals: " <> show number
            pure ()
        _ -> error "Failure"
