public with sharing class mars_CommunityServiceWorkerCtrl {
  public String getContent() {
    StaticResource worker = [
      SELECT Body FROM StaticResource WHERE Name = 'mars_CommunityServiceWorker' LIMIT 1
    ];
    return worker.Body.toString();
  }
}