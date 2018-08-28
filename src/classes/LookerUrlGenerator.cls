public class LookerUrlGenerator {

	private final String host = 'onrunning.eu.looker.com';
	private final String secret = '50a2f6865ac9bdc9c830fa27f8fad448363fe8a6ff7167bc3751717c46ca232f';
	private final String path;
	private final String nonce;
	private final String sessionLength;
	private final String currentTime;
	private final LookerUser user;

	public LookerUrlGenerator(String path, LookerUser user) {
		this.path = '/login/embed/' + EncodingUtil.urlEncode(path, 'UTF-8');
		this.user = user;
		this.nonce = JSON.serialize(generateRandomString(16));
		this.sessionLength = String.valueOf(86400);
		this.currentTime = JSON.serialize(datetime.now().getTime()/1000);
	}

	public String generateUrl(){
		String query_string = 'nonce=' + EncodingUtil.urlEncode(this.nonce, 'UTF-8')
			+ '&time=' + EncodingUtil.urlEncode(JSON.serialize(datetime.now().getTime()/1000), 'UTF-8')
			+ '&session_length=' + EncodingUtil.urlEncode(this.sessionLength, 'UTF-8')
			+ '&external_user_id=' + EncodingUtil.urlEncode(this.user.externalId, 'UTF-8')
			+ '&external_group_id=' + EncodingUtil.urlEncode(this.user.externalGroupId, 'UTF-8')
			+ '&group_ids=' + EncodingUtil.urlEncode(this.user.groupIds, 'UTF-8')
			+ '&permissions=' + EncodingUtil.urlEncode(this.user.permissions, 'UTF-8')
			+ '&models=' + EncodingUtil.urlEncode(this.user.models, 'UTF-8')
			+ '&user_attributes=' + EncodingUtil.urlEncode(this.user.attributes, 'UTF-8')
			+ '&access_filters=' + EncodingUtil.urlEncode(this.user.accessFilters, 'UTF-8')
			+ '&signature=' + EncodingUtil.urlEncode(this.generateSignature(), 'UTF-8')
			+ '&first_name=' + EncodingUtil.urlEncode(this.user.firstname, 'UTF-8')
			+ '&last_name=' + EncodingUtil.urlEncode(this.user.lastname, 'UTF-8')
			+ '&force_logout_login=' + EncodingUtil.urlEncode(String.valueOf(true), 'UTF-8');
		return 'https://' + this.host + this.path + '?' + query_string;
	}

	private String generateSignature(){
		String signature = String.join(new List<String>{
			this.host,
			this.path,
			this.nonce,
			this.currentTime,
			this.sessionLength,
			this.user.externalId,
			this.user.permissions,
			this.user.models,
			this.user.groupIds,
			this.user.externalGroupId,
			this.user.attributes,
			this.user.accessFilters
		}, '\n');
		Blob encrypted_string_to_sign = Crypto.generateMac('HMacSHA1', Blob.valueOf(signature), Blob.valueOf(this.secret));
		return EncodingUtil.base64Encode(encrypted_string_to_sign);
	}

	private String generateRandomString(Integer len) {
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		while (randStr.length() < len) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx+1);
		}
		return randStr; 
	}

	public class LookerUser {
		String externalId;
		String externalGroupId;
		String groupIds;
		String firstname;
		String lastname;
		String models;
		String permissions;
		String attributes;
		String accessFilters;

		public LookerUser(String externalId, String externalGroupId, List<Integer> groupIds, String firstname, String lastname, List<String> models, List<String> permissions, Map<String, String> attributes, Map<String, String> accessFilters){
			this.externalId = JSON.serialize(externalId);
			this.externalGroupId = JSON.serialize(externalGroupId);
			this.groupIds = JSON.serialize(groupIds);
			this.firstname = JSON.serialize(firstname);
			this.lastname = JSON.serialize(lastname);
			this.models = JSON.serialize(models);
			this.permissions = JSON.serialize(permissions);
			this.attributes = JSON.serialize(attributes);
			this.accessFilters = JSON.serialize(accessFilters);
		}
	}
}