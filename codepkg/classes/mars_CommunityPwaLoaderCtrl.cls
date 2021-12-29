public with sharing class mars_CommunityPwaLoaderCtrl {
  public String getContent() {
    StaticResource loader = [
      SELECT Body FROM StaticResource WHERE Name = 'mars_CommunityPwaLoader' LIMIT 1
    ];
    return loader.Body.toString();
  }
}