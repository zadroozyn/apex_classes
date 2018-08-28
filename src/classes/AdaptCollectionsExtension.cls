public class AdaptCollectionsExtension {
    public AdaptCollectionsExtension(ApexPages.StandardSetController stdController) { }

    public PageReference executeMethod(){
        CollectionMethods.adaptCollectionsForNewSeason();
        return new ApexPages.Action('{!list}').invoke();
    }
}