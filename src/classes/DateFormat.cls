public with sharing class DateFormat {

	private static String month = 'M',
			day = 'D',
			year = 'Y';

	public static final String FOR_CURRENT_USER = getDateFormatForCurrentUser();
	
	public static String getDateFormatForCurrentUser() {
		String sampleDate = Date.valueOf('3333-1-2 00:00:00').format();
		sampleDate = sampleDate.replaceAll('3', year).replaceAll('1', month).replaceAll('2', day);
		return findZeroes(sampleDate);
	}

	public static String getDateFormatForCurrentUser(String separator) {
		String dateFormat = getDateFormatForCurrentUser();
		String currentSeparator = getDateSeparator(dateFormat);
		if(currentSeparator.equals('.')) {
			currentSeparator = '\\.';
		}
		return dateFormat.replaceAll(currentSeparator, separator);
	}

	private static String findZeroes(String text) {
		while(text.indexOf('0') > -1) {
			text = text.replaceFirst('0', ''+text.subString(text.indexOf('0')+1, text.indexOf('0')+2));
		}
		return text;
	}

	public static Date getDateFromString(String val, String dateFormatString) {
		system.debug(val);
		system.debug(dateFormatString);
		if (String.isBlank(val)) {
			return null;
		}
		String separator = getDateSeparator(dateFormatString);
		if(separator.equals('.')){
			separator = '\\.';
		}
		List<String> dateValues = val.split(separator);
		List<String> dateComponents = dateFormatString.split(separator);
		Integer d,m,y;
		for(Integer i = 0; i < 3; i++) {
			if(dateComponents[i].containsIgnoreCase('d')){
				d = i;
			} else if(dateComponents[i].containsIgnoreCase('m')){
				m = i;
			} else if(dateComponents[i].containsIgnoreCase('y')){
				y = i;
			} 
		}
		return Date.valueOf(dateValues[y] + '-' + dateValues[m] + '-' + dateValues[d] + ' 00:00:00');
	}

	public static String getStringFromDate(Date dateToConvert, String dateFormatString) {
		if (dateToConvert == null) {
			return '';
		}
		String s = dateFormatString;
		s = s.replace('YYYY', addPrecedeZeroes(String.valueOf(dateToConvert.year()), 4));
		if(s.indexOf('MM') < 0){
			s = s.replace('M', String.valueOf(dateToConvert.month()));
		} else {
			s = s.replace('MM', addPrecedeZeroes(String.valueOf(dateToConvert.month()), 2));
		}
		if(s.indexOf('DD') < 0){
			s = s.replace('D', String.valueOf(dateToConvert.day()));
		} else {
			s = s.replace('DD', addPrecedeZeroes(String.valueOf(dateToConvert.day()), 2));
		}
		return s;
	}

	private static String getDateSeparator (String dateString) {
		for(Integer i = 0; i < dateString.length(); i++) {
			if(!dateString.subString(i, i+1).isAlphanumeric()){
				return dateString.subString(i, i+1);
			}
		}
		return null;
	}

	private static String addPrecedeZeroes ( String val, Integer desiredLength) {
		while(val.length() < desiredLength) {
			val = addPrecedeZero(val);
		}
		return val;
	}

	private static String addPrecedeZero ( String val ) {
		return '0' + val;
	}


}