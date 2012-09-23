sqlcmd -S .\sqlexpress -E -Q "create database Quran"
sqlcmd -S .\sqlexpress -E -d Quran -i "Quran.sql"