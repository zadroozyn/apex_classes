@isTest
class LookerUrlGeneratorTest {
	@isTest
	static void testGenerateUrl() {
		List<String> models = new List<String>{'backstage'};
		List<String> permissions = new List<String>{'access_data', 'see_looks'};
		Map<String, String> attributes = new Map<String, String>{'sf_account_id' => ''};
		LookerUrlGenerator.LookerUser lUser = new LookerUrlGenerator.LookerUser('38', '', new List<Integer>(), 'Test', 'McTest', models, permissions, attributes, new Map<String, String>());
		LookerUrlGenerator looker = new LookerUrlGenerator('/embed/looks/38', lUser);
		String lookerUrl = looker.generateUrl();
		System.assert(String.isNotBlank(lookerUrl));
	}
}