var starting_hash = "#HW=19,LL=1_38,LS=3,HA=21";
var cur_hw_page = 19, req_hw_page = 19;
var cur_ll_page = 38, req_ll_page = 38;
var cur_ll_vol = 1, req_ll_vol = 1;
var cur_ls_page = 3, req_ls_page = 3;
var cur_ha_page = 20, req_ha_page = 20;
var hw_hide = false, ll_hide = false, ls_hide = false, ha_hide = false;

function do_search(input) {
    var search = input;
    // TODO: converting all forms of alif and hamza                                             
    // (ء, آ, أ, ؤ, إ, ئ, ا) to a single character ء
    // Here's a funny hamza, what is it?
    // ha_p[25]="ءدب";
    // The same should be done for both forms of yaa (ي, ى)
    /*
		Perform search and replace mostly according to the Arabic Chat Alphabet:
		http://en.wikipedia.org/wiki/Arabic_chat_alphabet
	search = search.replace(//gi,"");
	*/
    // Normalize alifs and yas, not sure if this is right yet?
    search = search.replace(/[ﺀﺀﺁﺃﺅﺇﺉ]/g, "ا");
    search = search.replace(/[ﻯ]/g, "ي");
    // Firstly the letters that take IMHO 2 letters to transliterate
    search = search.replace(/th/g, "ث");
    search = search.replace(/gh/g, "غ");
    search = search.replace(/kh/g, "خ");
    search = search.replace(/sh/g, "ش");
    search = search.replace(/dh/g, "ذ");
    // Hmm, make the following case insensitive and assign different letters to different cases:
    search = search.replace(/d/g, "د");
    search = search.replace(/D/g, "ض");
    search = search.replace(/z/g, "ز");
    search = search.replace(/Z/g, "ظ");
    search = search.replace(/s/g, "س");
    search = search.replace(/S/g, "ص");
    search = search.replace(/t/g, "ت");
    search = search.replace(/T/g, "ط");
    search = search.replace(/h/g, "ه");
    search = search.replace(/H/g, "ح");
    // Not much iktilaaf over these I guess:
    search = search.replace(/a/g, "ا");
    search = search.replace(/b/g, "ب");
    search = search.replace(/j/g, "ج");
    search = search.replace(/7/g, "ح");
    search = search.replace(/r/g, "ر");
    search = search.replace(/3/g, "ع");
    search = search.replace(/E/g, "ع");
    search = search.replace(/e/g, "ع");
    search = search.replace(/f/g, "ف");
    search = search.replace(/q/g, "ق");
    search = search.replace(/k/g, "ك");
    search = search.replace(/l/g, "ل");
    search = search.replace(/m/g, "م");
    search = search.replace(/n/g, "ن");
    search = search.replace(/w/g, "و");
    search = search.replace(/y/g, "ي");
    //alert( "Searching for: " + search);
    // Headers 
    req_ha_page = binarySearch(ha_p, search, 0);
    req_hw_page = binarySearch(hw_p, search, -1);
    req_ll = get_ll_volume_page(binarySearch(ll_p, search, -1));
    req_ll_vol = req_ll[0];
    req_ll_page = req_ll[1];
    req_ls_page = binarySearch(ls_p, search, -1);

    return build_hash(search);
}

function build_hash(search) {
    var new_hash = "#HW=" + req_hw_page
		+ ",LL=" + req_ll_vol + "_" + req_ll_page
		+ ",LS=" + req_ls_page + ",HA=" + req_ha_page;
    return new_hash;
}

//Copyright 2009 Nicholas C. Zakas. All rights reserved.
//MIT-Licensed, see source file
function binarySearch(items, value, exact_match_fudge) {
    /*
        exact_match_fudge is the offset to return when an exact
        match is found. By default we track back at least 20 places
        to find the first occurance, however do we then return
        the first occurance or the one before?
        exact_match_fudge = 0 means yes (the former)
        exact_match_fudge = -1 means the one before
    */

    value = value.replace(/\s*/g, "");

    var startIndex = 0,
        stopIndex = items.length - 1,
        middle = Math.floor((stopIndex + startIndex) / 2),
				retval = 0;

    while (items[middle] != value && startIndex < stopIndex) {

        //adjust search area
        if (value < items[middle]) {
            stopIndex = middle - 1;
        } else if (value > items[middle]) {
            startIndex = middle + 1;
        }

        //recalculate middle
        middle = Math.floor((stopIndex + startIndex) / 2);
    }
    if (middle == 0) retval = 0;
    if (items[middle] == value) {
        // Trace back to a max of 20 items to get the first occurance of items[middle] == value
        for (i = 1; i < 20; i++) {
            if (items[middle - i] != value) {
                // Give the first match if searching for the start of a chapter
                if (value.length == 1 && exact_match_fudge == -1)
                    retval = middle - i + 2 + exact_match_fudge;
                else
                    retval = middle - i + 1 + exact_match_fudge;
                break;
            }

        }
    } else {
        //return (items[middle] != value) ? -1 : middle;
        //return (items[middle] > value && middle > 0) ? middle-1 : middle;
        //retval = (value > items[middle]) ? middle+1+exact_match_fudge : middle+exact_match_fudge;
        if (value > items[middle]) retval = middle + 1 + exact_match_fudge;
        else retval = middle + exact_match_fudge;
    }
    //debug( 'search = ' + value + ' retval = ' + retval + ' which is: ' + items[retval]);
    return retval;
}