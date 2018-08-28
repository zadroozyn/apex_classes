public abstract class B24SObjectCreatorBase implements B24SObjectCreator {

	public class AccountNotExistException extends Exception {}

	private Map<String, Account> mapGLN2Account;
	
	public B24SObjectCreatorBase() {
		mapGLN2Account = new Map<String, Account>();
	}

	public ParentChildren createSObject(B24MessageWrapper.MessageModel message, String messageId) {
		Set<String> glnNumbers = new Set<String>();
		glnNumbers.add(message.getBuyerGLN());
		glnNumbers.add(message.getSupplierGLN());
		glnNumbers.add(message.getSenderGLN());
		glnNumbers.add(message.getDeliveryPartyGLN());
		fetchRelevantAccountsByGLN(glnNumbers);
		return createSObjectImpl(message,messageId);
	}
	public abstract ParentChildren createSObjectImpl(B24MessageWrapper.MessageModel message, String messageId);

	private void fetchRelevantAccountsByGLN(Set<String> glnNumbers) {
		Set<String> setNewAccounts = glnNumbers.clone();
		setNewAccounts.remove('');
		setNewAccounts.remove(null);
		setNewAccounts.removeAll(mapGLN2Account.keySet());
		if(!setNewAccounts.isEmpty()) {
			List<Account> lAccs = [SELECT Id, Name, OwnerId, Billing_Name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone,
				ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, GLN__c,
				c2g__CODAAccountTradingCurrency__c, c2g__CODAFinanceContact__c
				FROM Account WHERE GLN__c IN :setNewAccounts];
			for(Account acc: lAccs) {
				mapGLN2Account.put(acc.GLN__c, acc);
			}
		}
	}

	protected Account getAccountByGLN(String glnNumber) {
		Account acc = mapGLN2Account.get(glnNumber);
		if(acc == null) {
			throw new AccountNotExistException('No Account with following GLN number exists: '+glnNumber);
		}
		return acc;
	}

	public class ParentChildren {
		public SObject parent;
		public List<SObject> children;
	}

	public interface IAddressSource {
		String getStreet1();
		String getStreet2();
		String getStreet3();
		String getPhone();
		String getName();
		String getCountry();
		String getCity();
		String getZipCode();
		String getState();
	}

	private class AddressProvider implements IAddressSource {
		public String street1;
		public String street2;
		public String street3;
		public String phone;
		public String name;
		public String country;
		public String city;
		public String zipCode;
		public String state;
		public String getStreet1() {
			return street1;
		}
		public String getStreet2() {
			return street2;
		}
		public String getStreet3() {
			return street3;
		}
		public String getPhone() {
			return phone;
		}
		public String getName() {
			return name;
		}
		public String getCountry() {
			return country;
		}
		public String getCity() {
			return city;
		}
		public String getZipCode() {
			return zipCode;
		}
		public String getState() {
			return state;
		}
	}

	public class AddressFactory {
		public IAddressSource getBillingAddress(Account accBuyer) {
			AddressProvider addr = new AddressProvider();
			addr.street1 = accBuyer.BillingStreet;
			addr.street2 = '';
			addr.street3 = '';
			addr.phone = accBuyer.Phone;
			addr.name = accBuyer.Name;
			addr.country = accBuyer.BillingCountry;
			addr.city = accBuyer.BillingCity;
			addr.zipCode  = accBuyer.BillingPostalCode;
			addr.state = accBuyer.BillingState;
			return addr;
		}

		public IAddressSource getShippingAddress(Account accBuyer) {
			AddressProvider addr = new AddressProvider();
			List<String> strLines = streetLines(accBuyer.ShippingStreet);
			addr.street1 = strLines[0];
			addr.street2 = strLines[1];
			addr.street3 = '';
			addr.phone = accBuyer.Phone;
			addr.name = accBuyer.Name;
			addr.country = accBuyer.ShippingCountry;
			addr.city = accBuyer.ShippingCity;
			addr.zipCode  = accBuyer.ShippingPostalCode;
			addr.state = accBuyer.ShippingState;
			return addr;
		}

		public IAddressSource getShippingAddress(B24MessageWrapper.OrderModel orderMsg) {
			AddressProvider addr = new AddressProvider();
			String address2 = '';
			if(orderMsg.deliveryParty.location.properties != null) {
				for(B24MessageWrapper.PropertyModel prop: orderMsg.deliveryParty.location.properties) {
					if(!String.isBlank(prop.code) && prop.code.equalsIgnoreCase('address2')) {
						address2 = prop.text;
						break;
					}
				}
			}
			addr.street1 = orderMsg.deliveryParty.location.address;
			addr.street2 = address2;
			addr.street3 = '';
			addr.phone = orderMsg.deliveryParty.location.telephoneNumber;
			addr.name = orderMsg.deliveryParty.name;
			String countryNameFromCode = COUNTRY_CODE_NAME_MAP.get(orderMsg.deliveryParty.location.country.code);
			String countryNameAsReceived = orderMsg.deliveryParty.location.country.text;
			addr.country = String.isBlank(countryNameFromCode) ? countryNameAsReceived : countryNameFromCode;
			addr.city = orderMsg.deliveryParty.location.city.text;
			addr.zipCode  = orderMsg.deliveryParty.location.city.code;
			if(orderMsg.deliveryParty.location.state != null) {
				String stateName = orderMsg.deliveryParty.location.state.text;
				String stateCode = orderMsg.deliveryParty.location.state.code;
				addr.state = !String.isBlank(stateName) ? stateName : stateCode;
			}
			
			return addr;
		}
		
		private List<String> streetLines(String street) {
			street = street == null ? '' : street;
			List<String> strLines = new List<String>{'',''};
			Integer firstLineLimit = 35; //KN limitation
			Integer secondLineLimit = 35; // also
			Integer firstLine = 0;
			Integer secondLine = 0;
			List<String> charArray = street.split('');
			for(Integer i=0; i<charArray.size(); i++) {
				if(firstLine < firstLineLimit) {
					strLines[0] += charArray[i];
					firstLine++;
				} else if(secondLine < secondLineLimit) {
					strLines[1] += charArray[i];
					secondLine++;
				} else {
					break;
				}
			}
			return strLines;
		}
	}

	private static final Map<String, String> COUNTRY_CODE_NAME_MAP = new Map<String, String>{
		'AF' => 'Afghanistan',
		'AX' => 'Åland Islands',
		'AL' => 'Albania',
		'DZ' => 'Algeria',
		'AS' => 'American Samoa',
		'AD' => 'Andorra',
		'AO' => 'Angola',
		'AI' => 'Anguilla',
		'AQ' => 'Antarctica',
		'AG' => 'Antigua and Barbuda',
		'AR' => 'Argentina',
		'AM' => 'Armenia',
		'AW' => 'Aruba',
		'AU' => 'Australia',
		'AT' => 'Austria',
		'AZ' => 'Azerbaijan',
		'BH' => 'Bahrain',
		'BS' => 'Bahamas',
		'BD' => 'Bangladesh',
		'BB' => 'Barbados',
		'BY' => 'Belarus',
		'BE' => 'Belgium',
		'BZ' => 'Belize',
		'BJ' => 'Benin',
		'BM' => 'Bermuda',
		'BT' => 'Bhutan',
		'BO' => 'Bolivia',
		'BQ' => 'Bonaire',
		'BA' => 'Bosnia and Herzegovina',
		'BW' => 'Botswana',
		'BV' => 'Bouvet Island',
		'BR' => 'Brazil',
		'IO' => 'British Indian Ocean Territory',
		'BN' => 'Brunei Darussalam',
		'BG' => 'Bulgaria',
		'BF' => 'Burkina Faso',
		'BI' => 'Burundi',
		'KH' => 'Cambodia',
		'CM' => 'Cameroon',
		'CA' => 'Canada',
		'CV' => 'Cape Verde',
		'KY' => 'Cayman Islands',
		'CF' => 'Central African Republic',
		'TD' => 'Chad',
		'CL' => 'Chile',
		'CN' => 'China',
		'CX' => 'Christmas Island',
		'CC' => 'Cocos (Keeling) Islands',
		'CO' => 'Colombia',
		'KM' => 'Comoros',
		'CG' => 'Congo',
		'CD' => 'Democratic Republic of the Congo',
		'CK' => 'Cook Islands',
		'CR' => 'Costa Rica',
		'CI' => 'Côte d\'Ivoire',
		'HR' => 'Croatia',
		'CU' => 'Cuba',
		'CW' => 'Curaçao',
		'CY' => 'Cyprus',
		'CZ' => 'Czech Republic',
		'DK' => 'Denmark',
		'DJ' => 'Djibouti',
		'DM' => 'Dominica',
		'DO' => 'Dominican Republic',
		'EC' => 'Ecuador',
		'EG' => 'Egypt',
		'SV' => 'El Salvador',
		'GQ' => 'Equatorial Guinea',
		'ER' => 'Eritrea',
		'EE' => 'Estonia',
		'ET' => 'Ethiopia',
		'FK' => 'Falkland Islands',
		'FO' => 'Faroe Islands',
		'FJ' => 'Fiji',
		'FI' => 'Finland',
		'FR' => 'France',
		'GF' => 'French Guiana',
		'PF' => 'French Polynesia',
		'TF' => 'French Southern Territories',
		'GA' => 'Gabon',
		'GM' => 'Gambia',
		'GE' => 'Georgia',
		'DE' => 'Germany',
		'GH' => 'Ghana',
		'GI' => 'Gibraltar',
		'GR' => 'Greece',
		'GL' => 'Greenland',
		'GD' => 'Grenada',
		'GP' => 'Guadeloupe',
		'GU' => 'Guam',
		'GT' => 'Guatemala',
		'GG' => 'Guernsey',
		'GN' => 'Guinea',
		'GW' => 'Guinea-Bissau',
		'GY' => 'Guyana',
		'HT' => 'Haiti',
		'HM' => 'Heard Island and McDonald Islands',
		'VA' => 'Vatican',
		'HN' => 'Honduras',
		'HK' => 'Hong Kong',
		'HU' => 'Hungary',
		'IS' => 'Iceland',
		'IN' => 'India',
		'ID' => 'Indonesia',
		'IR' => 'Iran',
		'IQ' => 'Iraq',
		'IE' => 'Ireland',
		'IM' => 'Isle of Man',
		'IL' => 'Israel',
		'IT' => 'Italy',
		'JM' => 'Jamaica',
		'JP' => 'Japan',
		'JE' => 'Jersey',
		'JO' => 'Jordan',
		'KZ' => 'Kazakhstan',
		'KE' => 'Kenya',
		'KI' => 'Kiribati',
		'KP' => 'North Korea',
		'KR' => 'Korea',
		'KW' => 'Kuwait',
		'KG' => 'Kyrgyzstan',
		'LA' => 'Lao People\'s Democratic Republic',
		'LV' => 'Latvia',
		'LB' => 'Lebanon',
		'LS' => 'Lesotho',
		'LR' => 'Liberia',
		'LY' => 'Libya',
		'LI' => 'Liechtenstein',
		'LT' => 'Lithuania',
		'LU' => 'Luxembourg',
		'MO' => 'Macao',
		'MK' => 'Macedonia',
		'MG' => 'Madagascar',
		'MW' => 'Malawi',
		'MY' => 'Malaysia',
		'MV' => 'Maldives',
		'ML' => 'Mali',
		'MT' => 'Malta',
		'MH' => 'Marshall Islands',
		'MQ' => 'Martinique',
		'MR' => 'Mauritania',
		'MU' => 'Mauritius',
		'YT' => 'Mayotte',
		'MX' => 'Mexico',
		'FM' => 'Micronesia',
		'MD' => 'Moldova',
		'MC' => 'Monaco',
		'MN' => 'Mongolia',
		'ME' => 'Montenegro',
		'MS' => 'Montserrat',
		'MA' => 'Morocco',
		'MZ' => 'Mozambique',
		'MM' => 'Myanmar',
		'NA' => 'Namibia',
		'NR' => 'Nauru',
		'NP' => 'Nepal',
		'NL' => 'Netherlands',
		'NC' => 'New Caledonia',
		'NZ' => 'New Zealand',
		'NI' => 'Nicaragua',
		'NE' => 'Niger',
		'NG' => 'Nigeria',
		'NU' => 'Niue',
		'NF' => 'Norfolk Island',
		'MP' => 'Northern Mariana Islands',
		'NO' => 'Norway',
		'OM' => 'Oman',
		'PK' => 'Pakistan',
		'PW' => 'Palau',
		'PS' => 'Palestine, State of',
		'PA' => 'Panama',
		'PG' => 'Papua New Guinea',
		'PY' => 'Paraguay',
		'PE' => 'Peru',
		'PH' => 'Philippines',
		'PN' => 'Pitcairn',
		'PL' => 'Poland',
		'PT' => 'Portugal',
		'PR' => 'Puerto Rico',
		'QA' => 'Qatar',
		'RE' => 'Réunion',
		'RO' => 'Romania',
		'RU' => 'Russian Federation',
		'RW' => 'Rwanda',
		'BL' => 'Saint Barthélemy',
		'SH' => 'Saint Helena',
		'KN' => 'Saint Kitts and Nevis',
		'LC' => 'Saint Lucia',
		'MF' => 'Saint Martin',
		'PM' => 'Saint Pierre and Miquelon',
		'VC' => 'Saint Vincent and the Grenadines',
		'WS' => 'Samoa',
		'SM' => 'San Marino',
		'ST' => 'Sao Tome and Principe',
		'SA' => 'Saudi Arabia',
		'SN' => 'Senegal',
		'RS' => 'Serbia',
		'SC' => 'Seychelles',
		'SL' => 'Sierra Leone',
		'SG' => 'Singapore',
		'SX' => 'Sint Maarten',
		'SK' => 'Slovakia',
		'SI' => 'Slovenia',
		'SB' => 'Solomon Islands',
		'SO' => 'Somalia',
		'ZA' => 'South Africa',
		'GS' => 'South Georgia',
		'SS' => 'South Sudan',
		'ES' => 'Spain',
		'LK' => 'Sri Lanka',
		'SD' => 'Sudan',
		'SR' => 'Suriname',
		'SJ' => 'Svalbard and Jan Mayen',
		'SZ' => 'Swaziland',
		'SE' => 'Sweden',
		'CH' => 'Switzerland',
		'SY' => 'Syrian Arab Republic',
		'TW' => 'Taiwan',
		'TJ' => 'Tajikistan',
		'TZ' => 'Tanzania',
		'TH' => 'Thailand',
		'TL' => 'Timor-Leste',
		'TG' => 'Togo',
		'TK' => 'Tokelau',
		'TO' => 'Tonga',
		'TT' => 'Trinidad and Tobago',
		'TN' => 'Tunisia',
		'TR' => 'Turkey',
		'TM' => 'Turkmenistan',
		'TC' => 'Turks and Caicos Islands',
		'TV' => 'Tuvalu',
		'UG' => 'Uganda',
		'UA' => 'Ukraine',
		'AE' => 'United Arab Emirates',
		'GB' => 'United Kingdom',
		'US' => 'United States',
		'UM' => 'United States Minor Outlying Islands',
		'UY' => 'Uruguay',
		'UZ' => 'Uzbekistan',
		'VU' => 'Vanuatu',
		'VE' => 'Venezuela, Bolivarian Republic of',
		'VN' => 'Vietnam',
		'VG' => 'Virgin Islands, British',
		'VI' => 'Virgin Islands, U.S.',
		'WF' => 'Wallis and Futuna',
		'EH' => 'Western Sahara',
		'YE' => 'Yemen',
		'ZM' => 'Zambia',
		'ZW' => 'Zimbabwe'
	};
}