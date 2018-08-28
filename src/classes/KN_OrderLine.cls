public interface KN_OrderLine {
    String getArticleID();
    String getArticleDescription();
    String getArticleEAN();
    Decimal getQuantity();
    String getUOM();
}