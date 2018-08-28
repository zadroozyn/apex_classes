public abstract class ONRAbstractParser
{
    protected PBSI__PBSI_Sales_Order__c order;
    protected String orderType = 'B2B';
    protected List<PBSI__PBSI_Sales_Order_Line__c> lineItems;
    protected List<PBSI__Shipped_Sales_Order_Line__c> packedLineItems;  
    protected List<PBSI__Shipped_Sales_Order_Line__c> packedTodayLineItems;  
    protected List<pw_ccpro__CountryObject__c> countryCodes;
    protected XmlStreamWriter xml;

    public virtual XmlStreamWriter toXML()
    {
        this.xml = this.objectToXML();
        return this.xml;
    }

    protected virtual XmlStreamWriter objectToXML()
    {
      XmlStreamWriter w = new XmlStreamWriter();
      w.writeStartDocument('UTF-8', '1.0'); // '<?xml version="1.0" encoding="UTF-8"?>'
      w.writeStartElement(null, 'root', null);
      w.writeEndElement();
      w.writeEndDocument();
      return w;
    }

    public String removeDotZero(String value)
    {
        return value.substringBefore('.');
    }

    public String stripIAY( String str )
    {
      return str == null ? '' : str.substring( 0, str.length()-3 );
    }

    public String get2DigitIso( String n, String d )
    {
      this.countryCodes = [SELECT pw_ccpro__IsoCode_2__c, pw_ccpro__IsoCode_3__c FROM pw_ccpro__CountryObject__c WHERE Name = :n];
      return this.countryCodes[0].pw_ccpro__IsoCode_2__c;
    }

    public String fitWithin( String value, Integer maxlength )
    {
        value = value.replaceAll('\r\n', '\n');
        value = value.replaceAll('\n\r', '\n');
        value = value.replaceAll('\n', ', ');
        if(value.length() < maxlength) {
            maxlength = value.length();
        }
        return value.substring(0, maxlength);
    }

    public String getDateFromDate(Date dt) {
      if( dt == null ) {
          return '2000-01-01';
      }
	  return String.valueOf(dt);
    }

    public String defaultString(String str, String defau) {
        return str == null ? defau : str;
    }

    public String getTimeFromDate( Date dt )
    {
      return '00:00:00-00:00';
    }

    public virtual String toXMLString()
    {
        this.xml = this.objectToXML();
        return this.xml.getXmlString();
    }
}