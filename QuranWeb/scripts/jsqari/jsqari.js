/*
 * jsQari: JavaScript Quran Recitation widget
 * http://www.qurantracker.com/jsQari
 *
 * Copyright (c) 2011 Ziad Mannan
 * Dual licensed under the MIT and GPL licenses.
 *  - http://www.opensource.org/licenses/mit-license.php
 *  - http://www.gnu.org/copyleft/gpl.html
 *
 * Author: Ziad Mannan
 * Contributor: Mohamad Ehab
 *    - linkedin: http://eg.linkedin.com/in/mohamadehab/
 *    - ODesk: https://www.odesk.com/users/~015620c5c655db4b75
 * Version: 1.3
 * Date: 17th Juy 2013
 */

var JSQari = function() {
	this.jsqariPlayer = $("#jquery_jplayer_1");
	this.jsqariBasmalahPlayed = false;
	this.jsqariSurahFrom;
	this.jsqariAyahFrom;
	this.jsqariSurahTo;
	this.jsqariAyahTo;
	this.jsqariRepeatAyah;
	this.jsqariRepeatSection;
	this.jsqariReciter;

	//Curr
	this.jsqariSurahCurr = 1;
	this.jsqariAyahCurr = 1;
	this.jsqariRepeatAyahCurr = 1;
	this.jsqariRepeatSectionCurr = 1;

	this.callback = null;
	
	this.surahAyahs = [0,7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,63,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6];
        this.surahNames = ["",
				"1. Al-Faatiha",
				"2. Al-Baqarah",
				"3. Aale 'Imran",
				"4. An-Nisaa",
				"5. Al-Maaidah",
				"6. Al-An'aam",
				"7. Al-A'raaf",
				"8. Al-Anfaal",
				"9. At-Tawbah",
				"10. Younus",
				"11. Huud",
				"12. Yusuf",
				"13. Ar-Ra'ad",
				"14. Ibraheem",
				"15. Al-Hijr",
				"16. An-Nahl",
				"17. Al-Israa",
				"18. Al-Kahf",
				"19. Maryam",
				"20. Taha",
				"21. Al-Anbiya",
				"22. Al-Hajj",
				"23. Al-Muminoon",
				"24. An-Noor",
				"25. Al-Furqaan",
				"26. Ash-Shu'araa",
				"27. An-Naml",
				"28. Al-Qasas",
				"29. Al-'Ankaboot",
				"30. Ar-Ruum",
				"31. Luqmaan",
				"32. As-Sajdah",
				"33. Al-Ahzaab",
				"34. Saba",
				"35. Faatir",
				"36. Yaseen",
				"37. As-Saffat",
				"38. Saad",
				"39. Az-Zumar",
				"40. Ghafir",
				"41. Fussilat",
				"42. Ash-Shura",
				"43. Az-Zukhruf",
				"44. Ad-Dukhan",
				"45. Al-Jathiya",
				"46. Al-Ahqaf",
				"47. Muhammad",
				"48. Al-Fath",
				"49. Al-Hujuraat",
				"50. Qaf",
				"51. Adh-Dhariyat",
				"52. At-Tur",
				"53. An-Najm",
				"54. Al-Qamar",
				"55. Ar-Rahman",
				"56. Al-Waqia",
				"57. Al-Hadid",
				"58. Al-Mujadila",
				"59. Al-Hashr",
				"60. Al-Mumtahina",
				"61. As-Saff",
				"62. Al-Jumua",
				"63. Al-Munafiqoon",
				"64. At-Taghabun",
				"65. At-Talaq",
				"66. At-Tahrim",
				"67. Al-Mulk",
				"68. Al-Qalam",
				"69. Al-Haaqqah",
				"70. Al-Ma'arij",
				"71. Nooh",
				"72. Al-Jinn",
				"73. Al-Muzzammil",
				"74. Al-Muddaththir",
				"75. Al-Qiyamah",
				"76. Al-Insaan",
				"77. Al-Mursalat",
				"78. An-Naba",
				"79. An-Naziat",
				"80. Abasa",
				"81. At-Takwir",
				"82. Al-Infitar",
				"83. Al-Mutaffifin",
				"84. Al-Inshiqaaq",
				"85. Al-Burooj",
				"86. At-Tariq",
				"87. Al-A'la",
				"88. Al-Ghashiyah",
				"89. Al-Fajr",
				"90. Al-Balad",
				"91. Ash-Shams",
				"92. Al-Lail",
				"93. Ad-Duha",
				"94. Ash-Sharh",
				"95. At-Tin",
				"96. Al-'Alaq",
				"97. Al-Qadr",
				"98. Al-Bayyinah",
				"99. Az-Zalzalah",
				"100. Al-'Adiyat",
				"101. Al-Qariyah",
				"102. At-Takathur",
				"103. Al-'Asr",
				"104. Al-Humazah",
				"105. Al-Fil",
				"106. Quraysh",
				"107. Al-Maoun",
				"108. Al-Kawthar",
				"109. Al-Kafiroon",
				"110. An-Nasr",
				"111. Al-Masad",
				"112. Al-Ikhlaas",
				"113. Al-Falaq",
				"114. An-Naas"];	
	this.uiSurahFromSelector = $('#jsqari-ui-surah-from-selector');
	this.uiAyahFromSelector = $('#jsqari-ui-ayah-from-selector');
	this.uiSurahToSelector = $('#jsqari-ui-surah-to-selector');
	this.uiAyahToSelector = $('#jsqari-ui-ayah-to-selector');
	this.uiRepeatAyahSelector = $('#jsqari-ui-repeat-ayah-selector');
	this.uiRepeatSectionSelector = $('#jsqari-ui-repeat-section-selector');
	this.uiReciterSelector = $('#jsqari-ui-reciter-selector');
	this.uiCurrentPlaying = $('#jsqari-ui-current-playing');

};

JSQari.prototype = {
	init : function () {
		var _this = this;
		
		this.jsqariSurahFrom = this.uiSurahFromSelector.val();
		this.jsqariAyahFrom = this.uiAyahFromSelector.val();
		this.jsqariSurahTo = this.uiSurahToSelector.val();
		this.jsqariAyahTo = this.uiAyahToSelector.val();
		this.jsqariRepeatAyah = this.uiRepeatAyahSelector.val();
		this.jsqariRepeatSection = this.uiRepeatSectionSelector.val();
		this.jsqariReciter = this.uiReciterSelector.val();
		this.jsqariBasmalahPlayed = true;

		this.jsqariPlayer.jPlayer({
			//ready: function () {
			//	$(_this.jsqariPlayer).jPlayer("setMedia", {
			//		mp3: "http://www.everyayah.com/data/Minshawy_Murattal_128kbps/001002.mp3"
			//	});
			//},
			ended: function() {
				_this.handleJSQariAyahEnd();
			},
			timeupdate: function(event) {
			        if ( (event.jPlayer.status.paused == true) && (event.jPlayer.status.srcSet == true))
				{
					_this.resetFlags();
				}
			},
			swfPath: "jsqari"
		});
						
		// set up event handlers
		this.uiSurahFromSelector.change(function() {
			_this.jsqariSurahFrom = parseInt($(this).val());
			_this.handleSurahFromChange();
			_this.modifySelectors();
			_this.updateUI();
			_this.setBasmalahStatus();
			_this.setMediaFile();
		});
		
		this.uiAyahFromSelector.change(function() {
			_this.jsqariAyahFrom = parseInt($(this).val());
			_this.handleAyahFromChange();
			_this.modifySelectors();
			_this.updateUI();
			_this.setBasmalahStatus();
			_this.setMediaFile();
		});

		// set up event handlers
		this.uiSurahToSelector.change(function() {
			_this.jsqariSurahTo = parseInt($(this).val());
			_this.handleSurahToChange();
			_this.handleToChange();
			_this.modifySelectors();
			_this.updateUI();
		});
		
		this.uiAyahToSelector.change(function() {
			_this.jsqariAyahTo = parseInt($(this).val());
			_this.handleToChange();
			_this.modifySelectors();
			_this.updateUI();
		});

		this.uiRepeatAyahSelector.change(function() {
			_this.jsqariRepeatAyah = parseInt($(this).val());
			//_this.jsqariRepeatAyahCurr = $(this).val();
			//_this.setBasmalahStatus();
			//_this.setMediaFile();
		});

		this.uiRepeatSectionSelector.change(function() {
			_this.jsqariRepeatSection = $(this).val();
			//_this.jsqariRepeatSectionCurr = $(this).val();
			//_this.setBasmalahStatus();
			//_this.setMediaFile();
		});

		
		this.uiReciterSelector.change(function() {
			_this.jsqariReciter = $(this).val();
			_this.setBasmalahStatus();
			_this.setMediaFile();
		});

		
		this.setMediaFile();
	},
	
	// CONTROLLER methods
	handleSurahFromChange : function() {
		if (this.jsqariPlayer.data('jPlayer').status.paused == false)
		{
			this.jsqariPlayer.jPlayer("stop");
		}
		
		this.jsqariAyahFrom = 1;
		this.jsqariSurahCurr = this.jsqariSurahFrom;
		this.jsqariAyahCurr = 1;
		if (this.jsqariSurahTo < this.jsqariSurahFrom)
		{
			this.jsqariSurahTo = this.jsqariSurahFrom;
			this.jsqariAyahTo = this.jsqariAyahFrom;
		}

	},

	handleAyahFromChange : function() {
		if (this.jsqariPlayer.data('jPlayer').status.paused == false)
		{
			this.jsqariPlayer.jPlayer("stop");
		}
		if (this.jsqariSurahTo == this.jsqariSurahFrom)
		{
			if (this.jsqariAyahTo < this.jsqariAyahFrom)
			{
				this.jsqariAyahTo = this.jsqariAyahFrom;
			}
			
		}
		this.jsqariAyahCurr = this.jsqariAyahFrom;
	},

	handleSurahToChange : function() {
		if (this.jsqariSurahTo == this.jsqariSurahFrom)
		{
			this.jsqariAyahTo = this.jsqariAyahFrom;
		}
		else
		{
			this.jsqariAyahTo = 1;
		}
	},

	handleToChange : function() {
		if (this.jsqariPlayer.data('jPlayer').status.paused == false)
		{
			if((this.jsqariSurahCurr > this.jsqariSurahTo) ||
			    ((this.jsqariSurahCurr == this.jsqariSurahTo) &&
			      (this.jsqariAyahCurr > this.jsqariAyahTo)))
			      {
				this.jsqariPlayer.jPlayer("stop");
				this.resetFlags();
			      }
		}
	},
	
	modifySelectors : function() {
		this.modifyAyahFromSelector();
		this.modifySurahToSelector();
		this.modifyAyahToSelector();
	},
	
	modifyAyahFromSelector : function() {
		this.uiAyahFromSelector.children().remove();
		var surahAyahNumber = this.surahAyahs[this.jsqariSurahFrom];
		for(i=1;i<=surahAyahNumber;i++) {
			this.uiAyahFromSelector.append('<option>' + i + '</option>');
		}
	},
	modifySurahToSelector : function() {
		this.uiSurahToSelector.children().remove();
		for(i=this.jsqariSurahFrom;i<=114;i++) {
			this.uiSurahToSelector.append('<option value=\"' + i +'\">' + this.surahNames[i] + '</option>');
		}
	},
	modifyAyahToSelector : function() {
		var surahAyahNumber = this.surahAyahs[this.jsqariSurahTo];
		var j;
		if(this.jsqariSurahTo == this.jsqariSurahFrom)
		{
			j = this.jsqariAyahFrom;
		}
		else
		{
			j = 1;
		}
		this.uiAyahToSelector.children().remove();
		for(i=j;i<=surahAyahNumber;i++) {
			this.uiAyahToSelector.append('<option>' + i + '</option>');
		}
	},

	handleJSQariAyahEnd : function (event) {
		if((this.jsqariSurahCurr == this.jsqariSurahTo) && (this.jsqariAyahCurr == this.jsqariAyahTo) && (this.jsqariRepeatAyahCurr == this.jsqariRepeatAyah)) {
				
				this.jsqariRepeatAyahCurr = 1;
				this.jsqariSurahCurr = this.jsqariSurahFrom;
				this.jsqariAyahCurr = this.jsqariAyahFrom;
				this.setBasmalahStatus();
				this.setMediaFile();

				//Check Section Repeat
				if (this.jsqariRepeatSection == "Infinite")
				{
					this.jsqariPlayer.jPlayer("play");
				}
				else if (this.jsqariRepeatSectionCurr < this.jsqariRepeatSection)
				{
					this.jsqariRepeatSectionCurr++;
					this.jsqariPlayer.jPlayer("play");
				}
				else
				{
				    //Reset data
				    this.jsqariRepeatSectionCurr = 1;
				}
			}
		else if (this.jsqariRepeatAyahCurr < this.jsqariRepeatAyah) {
				if (this.jsqariAyahCurr == 0)
				{
					this.jsqariAyahCurr = 1;
				}
				else
				{
					this.jsqariRepeatAyahCurr++;
				}
				this.setMediaFile();
				this.jsqariPlayer.jPlayer("play");
			}
		else { //Move to next Ayah
			if (this.jsqariAyahCurr == 0)
			{
				this.jsqariAyahCurr = 1;
			}
			else
			{
				this.jsqariRepeatAyahCurr = 1;
				this.jsqariAyahCurr = parseInt(this.jsqariAyahCurr) + 1;
				if(this.jsqariAyahCurr > this.surahAyahs[this.jsqariSurahCurr]) {
					this.jsqariAyahCurr = 1;
					this.jsqariSurahCurr = parseInt(this.jsqariSurahCurr) + 1;
					if(this.jsqariSurahCurr > 114) {
						this.jsqariSurahCurr = 1;
					}
					this.setBasmalahStatus();
				}
			}
			this.setMediaFile();
			this.jsqariPlayer.jPlayer("play");
		} 
		//this.updateUI();
	},

	// VIEW functions
	handleCurrChange: function(isBasmalah) {
		if ((isBasmalah == true) || (this.jsqariAyahCurr == 0))
		{
		    this.uiCurrentPlaying.val('Basmalah');		    
		}
		else
		{
			this.uiCurrentPlaying.val(this.surahNames[this.jsqariSurahCurr] + ':' + this.jsqariAyahCurr);
		}
		if (typeof this.callback == "function")
		    this.callback(this.jsqariSurahCurr, this.jsqariAyahCurr);
	},
	updateUI : function() {
		this.uiSurahFromSelector.val(this.jsqariSurahFrom);
		this.uiAyahFromSelector.val(this.jsqariAyahFrom);
		this.uiSurahToSelector.val(this.jsqariSurahTo);
		this.uiAyahToSelector.val(this.jsqariAyahTo);
		this.uiRepeatAyahSelector.val(this.jsqariRepeatAyah);
		if(this.jsqariRepeatSection == 0)
		{
			this.uiRepeatSectionSelector.val("Infinite");
		}
		else
		{
			this.uiRepeatSectionSelector.val(this.jsqariRepeatSection);
		}
		//this.uiCurrentPlaying.val(this.surahNames[this.jsqariSurahCurr] + ':' + this.jsqariAyahCurr);
	},
	
	// API functions
	
	// play the surah provided
	playSurah : function(surahNumber) {
		return this.playSurahAyah(surahNumber, 1,false);
	},
	
	// play from the surah/ayah provided. If endOfQuran is true then it plays to the end of the Quran
	// if it is false then plays to the end of the surah
	playSurahAyah : function(surahNumber, ayahNumber,endOfQuran) {
		
		if (this.jsqariPlayer.data('jPlayer').status.paused == false)
		{
			this.jsqariPlayer.jPlayer("stop");
		}
		// check surah number
		surahNumberParsed = parseInt(surahNumber);
		if(isNaN(surahNumberParsed)) {
			alert('Surah number is not a valid number');
			return false;
		} else if (surahNumberParsed > 114 || surahNumberParsed < 1) {
			alert('Not a valid surah number');
			return false;
		}
		
		// check ayah number
		ayahNumberParsed = parseInt(ayahNumber);
		if(isNaN(ayahNumberParsed)) {
			alert('Ayah number is not a valid number');
			return false;
		} else if (ayahNumberParsed > this.surahAyahs[surahNumberParsed] || ayahNumberParsed < 1) {
			alert('Not a valid ayah number');
			return false;
		}
		
		this.jsqariSurahFrom = surahNumberParsed;
		this.jsqariAyahFrom = ayahNumberParsed;
		this.jsqariSurahCurr = this.jsqariSurahFrom;
		this.jsqariAyahCurr = this.jsqariAyahFrom;
		
		if (endOfQuran == false)
		{
			this.jsqariSurahTo = this.jsqariSurahFrom;
			this.jsqariAyahTo = this.surahAyahs[surahNumberParsed];
		}
		else
		{
			this.jsqariSurahTo = 114;
			this.jsqariAyahTo = this.surahAyahs[114]
		}
		this.setBasmalahStatus();
		this.modifySelectors();
		this.updateUI();
		this.setMediaFile();
		this.jsqariPlayer.jPlayer("play");
	},

	// set the from surah/ayah and to surah/ayah and play
	playSection : function(surahNumber, ayahNumber, surahNumberTo, ayahNumberTo) {
		
		this.setFromToPosition(surahNumber,ayahNumber,surahNumberTo,ayahNumberTo);
		this.play();
	},

	// set the from surah/ayah and to surah/ayah
	setFromToPosition : function(surahNumber, ayahNumber, surahNumberTo, ayahNumberTo) {
		
		this.setFromPosition(surahNumber,ayahNumber);
		this.setToPosition(surahNumberTo,ayahNumberTo);
	},

	// play from this surah/ayah
	setFromPosition : function(surahNumber, ayahNumber) {
		
		// check surah number
		surahNumberParsed = parseInt(surahNumber);
		if(isNaN(surahNumberParsed)) {
			alert('Surah number is not a valid number');
			return false;
		} else if (surahNumberParsed > 114 || surahNumberParsed < 1) {
			alert('Not a valid surah number');
			return false;
		}
		
		// check ayah number
		ayahNumberParsed = parseInt(ayahNumber);
		if(isNaN(ayahNumberParsed)) {
			alert('Ayah number is not a valid number');
			return false;
		} else if (ayahNumberParsed > this.surahAyahs[surahNumberParsed] || ayahNumberParsed < 1) {
			alert('Not a valid ayah number');
			return false;
		}
		
		if(this.jsqariSurahFrom != surahNumberParsed) {
			this.jsqariSurahFrom = surahNumberParsed;
			this.handleSurahFromChange();
		}
		
		this.jsqariAyahFrom = ayahNumberParsed;
		this.handleAyahFromChange();
		this.modifySelectors();
		this.setBasmalahStatus();
		this.setMediaFile();

		this.updateUI();
	},

	// play to this surah/ayah
	setToPosition : function(surahNumber, ayahNumber) {
		
		// check surah number
		surahNumberParsed = parseInt(surahNumber);
		if(isNaN(surahNumberParsed)) {
			alert('Surah number is not a valid number');
			return false;
		} else if (surahNumberParsed > 114 || surahNumberParsed < 1) {
			alert('Not a valid surah number');
			return false;
		}
		
		// check ayah number
		ayahNumberParsed = parseInt(ayahNumber);
		if(isNaN(ayahNumberParsed)) {
			alert('Ayah number is not a valid number');
			return false;
		} else if (ayahNumberParsed > this.surahAyahs[surahNumberParsed] || ayahNumberParsed < 1) {
			alert('Not a valid ayah number');
			return false;
		} else if ((surahNumberParsed < this.jsqariSurahFrom) || ((surahNumberParsed == this.jsqariSurahFrom) && (ayahNumberParsed < this.jsqariAyahFrom))){
			alert('To Ayah is before From Ayah');
			return false;
		}

		
		if(this.jsqariSurahTo != surahNumberParsed) {
			this.jsqariSurahTo = surahNumberParsed;
			this.handleSurahToChange();
		}
		
		this.jsqariAyahTo = ayahNumberParsed;
		this.handleToChange();
		this.modifySelectors();
		this.updateUI();
	},

	// set how many times the section (from - to) should be repeated. A value of 0 sets the repeat to be infinite
	setRepeatSection : function(repeatNumber) {
		
		// check surah number
		repeatNumberParsed = parseInt(repeatNumber);
		if(isNaN(repeatNumberParsed)) {
			alert('Repeat Surah number is not a valid number');
			return false;
		} else if (repeatNumberParsed == 0) {
			this.jsqariRepeatSection = "Infinite";
		}else {
			this.jsqariRepeatSection = repeatNumberParsed;
		}
		this.updateUI();
	},	

	// set how many times an ayah should be repeated
	setRepeatAyah : function(repeatNumber) {
		
		// check surah number
		repeatNumberParsed = parseInt(repeatNumber);
		if(isNaN(repeatNumberParsed) || repeatNumberParsed == 0) {
			alert('Repeat Surah number is not a valid number');
			return false;
		}else {
			this.jsqariRepeatAyah = repeatNumberParsed;
		}
		this.updateUI();
	},	
	
	play : function() {
		
		this.setBasmalahStatus();
		//this.updateUI();
		this.setMediaFile();
		this.jsqariPlayer.jPlayer("play");
	},

	stop : function() {		
		this.jsqariPlayer.jPlayer("stop");
		this.resetFlags();
	},

	// sets the play mode (legacy API method)
	// possible values are continious, repeatayah, singleayah, surah, repeatsurah
	setPlayMode : function(pMode) {
		if(pMode == 'continious') {
			// go to next ayah and play again
			this.jsqariSurahTo = 114;
			this.jsqariAyahTo = this.surahAyahs[114];
			this.jsqariRepeatAyah = 1;
			this.jsqariRepeatSection = 1;
		} else if (pMode == 'repeatayah') {
			this.jsqariSurahTo = this.jsqariSurahCurr;
			this.jsqariAyahTo = this.jsqariAyahCurr;
			this.jsqariSurahFrom = this.jsqariSurahCurr;
			this.jsqariAyahFrom = this.jsqariAyahCurr;
			this.jsqariRepeatAyah = 1;
			this.jsqariRepeatSection = "Infinite";
		} else if (pMode == 'singleayah') {
			this.jsqariSurahTo = this.jsqariSurahCurr;
			this.jsqariAyahTo = this.jsqariAyahCurr;
			this.jsqariSurahFrom = this.jsqariSurahCurr;
			this.jsqariAyahFrom = this.jsqariAyahCurr;
			this.jsqariRepeatAyah = 1;
			this.jsqariRepeatSection = 1;
		} else {
			var wasPlaying = false;
			if (pMode == 'surah') {
				if (this.jsqariPlayer.data('jPlayer').status.paused == false)
				{
					this.jsqariPlayer.jPlayer("stop");
					wasPlaying = true;
				}
				this.jsqariSurahFrom = this.jsqariSurahCurr;
				this.jsqariSurahTo = this.jsqariSurahCurr;
				this.jsqariAyahTo = this.surahAyahs[this.jsqariSurahFrom];
				this.jsqariAyahFrom = 1;
				this.jsqariSurahCurr = this.jsqariSurahFrom;
				this.jsqariAyahCurr = 1;
				this.jsqariRepeatAyah = 1;
				this.jsqariRepeatSection = 1;
			} else if (pMode == 'repeatsurah') {
				if (this.jsqariPlayer.data('jPlayer').status.paused != false)
				{
					this.jsqariSurahCurr = this.jsqariSurahFrom;
					this.jsqariAyahCurr = 1;
				}
				this.jsqariSurahFrom = this.jsqariSurahCurr;
				this.jsqariSurahTo = this.jsqariSurahCurr;
				this.jsqariAyahTo = this.surahAyahs[this.jsqariSurahFrom];
				this.jsqariAyahFrom = 1;
				this.jsqariRepeatAyah = 1;
				this.jsqariRepeatSection = "Infinite";
			}
			if (wasPlaying == true)
			{
				this.play();
			}
			
		}
		this.modifySelectors();
		this.updateUI();
	},
	
	// 'PRIVATE' functions
	setMediaFile : function () {
		// handle basmalah
		var tempSurah = false;
		var tempSurahNumber;
		
		if (!this.jsqariBasmalahPlayed) {
			this.handleCurrChange(true);
			tempSurah = true;
			tempSurahNumber = this.jsqariSurahCurr;
			this.jsqariSurahCurr = 1;
			this.jsqariAyahCurr = 1;
			this.jsqariBasmalahPlayed = true;
		}
		else
		{
			this.handleCurrChange(false);
		}
		var base = 'http://www.everyayah.com/data/';
		var mp3file = base + this.jsqariReciter + this.pad(this.jsqariSurahCurr, 3) + this.pad(this.jsqariAyahCurr, 3) + '.mp3';

		if (tempSurah) {
			this.jsqariSurahCurr = tempSurahNumber;
			this.jsqariAyahCurr = 0;
		}
		
		//alert(mp3file);
		this.jsqariPlayer.jPlayer("setMedia", {mp3: mp3file});
		//this.handleCurrChange();
		
	},
	
	setBasmalahStatus : function() {
		if (this.jsqariAyahCurr == 1 && (this.jsqariSurahCurr != 1 && this.jsqariSurahCurr != 9)) {
			this.jsqariBasmalahPlayed = false;
		} else {
			this.jsqariBasmalahPlayed = true;
		}
	},

	pad : function(number, length) {
		var str = '' + number;
		while (str.length < length) {
			str = '0' + str;
		}
		return str;
	},
	
	resetFlags : function() {
		this.jsqariRepeatAyahCurr = 1;
		this.jsqariRepeatSectionCurr = 1;
		this.jsqariSurahCurr = this.jsqariSurahFrom;
		this.jsqariAyahCurr = this.jsqariAyahFrom;
		this.setBasmalahStatus();
		this.setMediaFile();
	}
}
