The project is in Visual Studio 2012 format. Please download Visual Studio 2012 Express and launch the solution. Or you can create Visual Studio 2010 solution and just add all the files yourself. Best if you keep in VS 2012.

First you have to setup the database. Go to the database folder and follow the readme to setup the Quran database.

Then you just run the solution and it should work. Visual Studio might warn you about some missing files, ignore them. Just delete those files from solution and build the solution. 



Modification History:
---------------------

02 Sep 2012: Author:mdismail
	Issue # 2: Language Filter implemented.
	Changes Items:
	1.\QuranWeb\Default.aspx
	2.\QuranWeb\Default.aspx.cs
	3.\QuranObjects\DataClasses.cs
	4.\Database\021 LanguageFilterScript.sql
	5.\Database\051 SurahNames Schema.sql
	6.\Database\052 SurahNames Data.sql
