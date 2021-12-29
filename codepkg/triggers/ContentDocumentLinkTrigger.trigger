/**
 * Created by Pankaj on 11-05-2020.
 */

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, after insert, after update) {
    new ContentDocumentLinkTriggerHelper().process();
}