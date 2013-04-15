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
 * Version: 1.2.1
 * Date: 9th May 2012
 */

var JSQari = function() {
	this.jsqariPlayer = $("#jquery_jplayer_1");
	this.jsqariBasmalahPlayed = false;
	this.jsqariSurah;
	this.jsqariAyah;
	this.jsqariReciter;
	this.jsqariMode;
	
	this.surahAyahs = [0,7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,63,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6];
	
	this.uiSurahSelector = $('#jsqari-ui-surah-selector');
	this.uiAyahSelector = $('#jsqari-ui-ayah-selector');
	this.uiReciterSelector = $('#jsqari-ui-reciter-selector');
	this.uiModeSelector = $('#jsqari-ui-mode-selector');

};

JSQari.prototype = {
	init : function () {
		var _this = this;
		
		this.jsqariSurah = this.uiSurahSelector.val();
		this.jsqariAyah = this.uiAyahSelector.val();
		this.jsqariReciter = this.uiReciterSelector.val();
		this.jsqariMode = this.uiModeSelector.val();
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
			swfPath: "jsqari"			
		});
						
		// set up event handlers
		this.uiSurahSelector.change(function() {
			_this.jsqariSurah = $(this).val();
			_this.handleSurahChange();
			_this.setMediaFile();
		});
		
		this.uiAyahSelector.change(function() {
			_this.jsqariAyah = $(this).val();
			_this.setBasmalahStatus();
			_this.setMediaFile();
		});

		this.uiReciterSelector.change(function() {
			_this.jsqariReciter = $(this).val();
			_this.setBasmalahStatus();
			_this.setMediaFile();
		});

		this.uiModeSelector.change(function() {
			_this.jsqariMode = $(this).val();
			_this.setBasmalahStatus();
			_this.setMediaFile();
		});
		
		this.setMediaFile();
	},
	
	// CONTROLLER methods
	handleSurahChange : function() {
		this.jsqariAyah = 1;
		this.setBasmalahStatus();
		this.uiAyahSelector.children().remove();
		var surahAyahNumber = this.surahAyahs[this.jsqariSurah];
		for(i=1;i<=surahAyahNumber;i++) {
			this.uiAyahSelector.append('<option>' + i + '</option>');
		}
	},

	handleJSQariAyahEnd : function (event) {
		if(this.jsqariMode == 'continious') {
			// go to next ayah and play again
			this.jsqariAyah = parseInt(this.jsqariAyah) + 1;
			if(this.jsqariAyah > this.surahAyahs[this.jsqariSurah]) {
				this.jsqariAyah = 1;
				this.jsqariSurah = parseInt(this.jsqariSurah) + 1;
				if(this.jsqariSurah > 114) {
					this.jsqariSurah = 1;
				}
				this.handleSurahChange();
			}
			this.setMediaFile();
			this.jsqariPlayer.jPlayer("play");
		} else if (this.jsqariMode == 'repeatayah') {
			// play again
			if (this.jsqariAyah == 0) {
				this.jsqariAyah = 1;
				this.setMediaFile();
			}
			this.jsqariPlayer.jPlayer("play");
		} else if (this.jsqariMode == 'singleayah') {
			// play first ayah after basmalah
			if (this.jsqariAyah == 0) {
				this.jsqariAyah = 1;
				this.setMediaFile();
				this.jsqariPlayer.jPlayer("play");
			}
		} else if (this.jsqariMode == 'surah') {
			// play to end of surah
			if(this.jsqariAyah < this.surahAyahs[this.jsqariSurah]) {
				this.jsqariAyah = parseInt(this.jsqariAyah) + 1;
				this.setMediaFile();
				this.jsqariPlayer.jPlayer("play");
			}
		} else if (this.jsqariMode == 'repeatsurah') {
			// play to end of surah
			if(this.jsqariAyah < this.surahAyahs[this.jsqariSurah]) {
				this.jsqariAyah = parseInt(this.jsqariAyah) + 1;
				this.setMediaFile();
				this.jsqariPlayer.jPlayer("play");
			} else {
				this.jsqariAyah = 1;
				this.setBasmalahStatus();
				this.setMediaFile();
				this.jsqariPlayer.jPlayer("play");
			}
		}
		this.updateUI();
	},

	// VIEW functions
	updateUI : function() {
		this.uiSurahSelector.val(this.jsqariSurah);
		this.uiAyahSelector.val(this.jsqariAyah);
		this.uiModeSelector.val(this.jsqariMode);
	},
	
	// API functions
	setPlayMode : function (playMode) {
		this.jsqariMode = playMode;
		this.updateUI();
	},
	
	playSurah : function(surahNumber) {
		return this.playSurahAyah(surahNumber, 1);
	},
	
	playSurahAyah : function(surahNumber, ayahNumber) {
		
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
		
		if(this.jsqariSurah != surahNumberParsed) {
			this.jsqariSurah = surahNumberParsed;
			this.handleSurahChange();
		}
		
		this.jsqariAyah = ayahNumberParsed;
		this.setBasmalahStatus();
		this.updateUI();
		this.setMediaFile();
		this.jsqariPlayer.jPlayer("play");
	},
	
	// 'PRIVATE' functions
	setMediaFile : function () {
		// handle basmalah
		var tempSurah = false;
		var tempSurahNumber;
		if (!this.jsqariBasmalahPlayed) {
			tempSurah = true;
			tempSurahNumber = this.jsqariSurah;
			this.jsqariSurah = 1;
			this.jsqariAyah = 1;
			this.jsqariBasmalahPlayed = true;
		}
		
		var base = 'http://www.everyayah.com/data/';
		var mp3file = base + this.jsqariReciter + this.pad(this.jsqariSurah, 3) + this.pad(this.jsqariAyah, 3) + '.mp3';

		if (tempSurah) {
			this.jsqariSurah = tempSurahNumber;
			this.jsqariAyah = 0;
		}
		
		//alert(mp3file);
		this.jsqariPlayer.jPlayer("setMedia", {mp3: mp3file});
		
	},
	
	setBasmalahStatus : function() {
		if (this.jsqariAyah == 1 && (this.jsqariSurah != 1 && this.jsqariSurah != 9)) {
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
	}
	
}
