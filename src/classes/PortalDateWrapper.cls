/**
  This class wraps date field for use in text inputs on Portal pages.
  It hold data in Date field, which is used on SF side, while it also
  have a string field that returns string representation of date, with
  formatting specified in dateFormatString
  */
public with sharing class PortalDateWrapper {

	final private String dateFormatString;

	public Date dateField { public get; public set; }

	public String textField {
		public get {
			return DateFormat.getStringFromDate(this.dateField, this.dateFormatString);
		}
		public set {
			this.dateField	= DateFormat.getDateFromString(value, this.dateFormatString);
		}
	}

	public PortalDateWrapper (String dateFormatString) {
		this.dateFormatString = dateFormatString;
		this.dateField = Date.today();
	}

	public PortalDateWrapper (Date dateToRepresent, String dateFormatString) {
		this(dateFormatString);
		this.dateField = dateToRepresent;
	}

}