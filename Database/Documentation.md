# Introduction to the tables
There are three types of table:
* Tables generated from corpus.quran.com that holds the root -> grammar form -> arabic word -> occurrence mapping. 
* Tables for holding translations taken from islamawakened.com
* Table for holding the in progress Bangla translation.

# Roots Table
## Introduction
Holds all Root Arabic words that have appeared in Quran. 

![Root table](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20Root.png)


## Columns
* RootCode - An English representation of the Arabic alphabet. The mapping table is given below.
* Root English - Transliteration of the Arabic alphabets
* Meanings - Meanings of the root scrapped from Project Root list.
* RootArabic - The Root Arabic form
* BanglaMeanings - In progress Bangla meaning of the Roots.


## Arabic to English alphabet mapping

	A	أ	Alif
	b	ب	Ba
	t	ت	Ta
	v	ث	Tha
	j	ج	Jiim
	H	ح	Ha
	x	خ	Kha
	d	د	Dal
	*	ذ	Thal
	r	ر	Ra
	z	ز	Zay
	s	س	Siin
	$	ش	Sh
	S	ص	Sad
	D	ض	Dad
	T	ط	Tay
	Z	ظ	Za
	E	ع	Ayn
	g	غ	Gh
	f	ف	Fa
	q	ق	Qaf
	k	ك	Kaf
	l	ل	Lam
	m	م	Miim
	n	ن	Nun
	h	ه	ha
	w	و	Waw
	y	ي	Ya`


# Grammar Form Table
## Introduction
This table holds the unique grammar forms of each root word as it appears in Quran. This is most likely not completely populated as it has some missing occurrences in corpus.quran.com which is available in Tanzil project. 

![](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20GrammarForms.png)


## Columns ##
- RootID - Foreign Key to Root
- Grammar - The gramatical form of the Root. 
- Occurrences - Number of times the Root in the Grammatical form has appeared in Quran. To be calculated once all the grammatical forms are calculated. 

## Todo
Since there are missing grammatical forms in corpus, we need to create some dummy grammatical form for each mising Root occurrence in the Quran and map it to the Word for now. 


# ArabicWord Table
## Introduction
This table contains unique Arabic words found in Quran and its grammatical form. However, not all unique forms are captured yet, since not all grammatical forms have been identified yet. 

![](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20Arabic.png)

## Columns
- GrammarFormID - Foreign Key to Grammar Form ID.
- RootID - Foreign Key to Root.
- Arabic - Arabic transliteration
- Occurrences - Number of times this Arabic word in the grammatical form appears in Quran. This count is not fully accurate yet since Corpus has missing grammatical forms.
- Simplified - Simplified transliteration which can be used to perform Searches in Quran. 

## Todo
- Some Arabic words are missing here because corpus.quran.com hasn't mapped all grammatical forms properly yet. Since it has foreign key to GrammarForm table, if a GrammarForm is missing, all the unique Arabic words of that GrammarForm is also missing.
- Phonetic - Add a new column to capture the phonetic form of the word so that we can do phonetic search.


# Meanings Table
## Introduction
All words in Quran is available in this table. Or is supposed to be. Since corpus has missing grammar form mapping, there are missing words in this table as well. 

![](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20Meanings.png)

## Columns
- SurahNo - duh!
- VerseNo - duh!
- WordNo - duh!
- ArabicWordID - Foreign Key to ArabicWord.
- EnglishMeaning - The meaning of this particular occurrence of the arabic word in the word by word translation of corpus.quran.com.
- RootID - Root of the Arabic word. Duplicated in this table for faster lookup to the Root.
- GrammarFormID - The grammar form of the Arabic Word. Duplicated in this table for faster lookup to the Grammar form.

## Todo
- There are missing words in corpus which we need to find using tanzil database and fill up.

# Ayahs Table
## Introduction
Translation of verses of Quran is collected from islamawakened.com and stored here. 

![](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20Ayahs.png)


# Translators table
## Introduction
Name of the translators and type of translation is stored here.

![](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20Translators.png)

## Columns
- Name - Name of translator.
- Order - In which order translation should be rendered.
- Type - 0 = Arabic, 1 = Accepted translations, 2 = Controlversal translations, 3 = Non muslim translators, 4 = English transliteration
- ShowDefault - if true, it is shown as default to new users.

## Todo
- Introduce a language table so that translations can be categorized by language and filtered by language. 


# MyTranslation table
## Introduction
Work in progress Contemporary Bangla translation.

![](https://raw.github.com/oazabir/Quran/master/Docs/Screenshots/Table%20-%20MyTranslations.png)

## Columns
- SurahNo
- AyahNo
- Heading - The heading/topic of a group of verse. 
- Translation - The Bangla translation of the verse. Translation table contains * to mark footnote. First footnote is *, second is **, third is *** and so on.
- Footnote - Footnotes from the translation. 