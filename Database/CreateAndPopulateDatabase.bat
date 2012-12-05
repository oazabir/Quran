sqlcmd -S "(localdb)\Projects" -E -i "Quran.sql"
sqlcmd -S "(localdb)\Projects" -E -i "021 LanguageFilterScript.sql"
sqlcmd -S "(localdb)\Projects" -E -i "051 SurahNames Schema.sql"
sqlcmd -S "(localdb)\Projects" -E -i "052 SurahNames Data.sql"