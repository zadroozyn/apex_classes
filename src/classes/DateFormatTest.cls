@isTest
public with sharing class DateFormatTest {

	@isTest private static void en_USTest() {
		String s;
		System.runAs(getUserWithLocale('en_US')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('M/D/YYYY', s);
	}

	@isTest private static void en_GBTest() {
		String s;
		System.runAs(getUserWithLocale('en_GB')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD/MM/YYYY', s);
	}

	@isTest private static void fi_FITest() {
		String s;
		System.runAs(getUserWithLocale('fi_FI')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('D.M.YYYY', s);
	}

	@isTest private static void fr_CATest() {
		String s;
		System.runAs(getUserWithLocale('fr_CA')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('YYYY-MM-DD', s);
	}

	@isTest private static void lt_LTTest() {
		String s;
		System.runAs(getUserWithLocale('lt_LT')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('YYYY.M.D', s);
	}

	@isTest private static void pl_PLTest() {
		String s;
		System.runAs(getUserWithLocale('pl_PL')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD.MM.YYYY', s);
	}

	@isTest private static void pt_PTTest() {
		String s;
		System.runAs(getUserWithLocale('pt_PT')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD-MM-YYYY', s);
	}

	@isTest private static void fr_FRTest() {
		String s;
		System.runAs(getUserWithLocale('fr_FR')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD/MM/YYYY', s);
	}

	@isTest private static void de_DETest() {
		String s;
		System.runAs(getUserWithLocale('de_DE')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD.MM.YYYY', s);
	}
	
	@isTest private static void de_CHTest() {
		String s;
		System.runAs(getUserWithLocale('de_CH')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD.MM.YYYY', s);
	}
	
	@isTest private static void fr_CHTest() {
		String s;
		System.runAs(getUserWithLocale('fr_CH')) {
			s = DateFormat.getDateFormatForCurrentUser();
		}
		System.assertEquals('DD.MM.YYYY', s);
	}
	
	private static User getUserWithLocale(String locale) {
		return new User(Alias = 'Test', Email='test@example.com', EmailEncodingKey='UTF-8', Lastname='Test', LanguageLocaleKey='en_US', LocaleSidKey=locale, ProfileId = UserInfo.getProfileId(), TimeZonesIdKey='America/Los_Angeles', Username='dateFormatTest@example.com');
	}
}