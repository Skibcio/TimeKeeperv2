package Scripts
{
	import flash.text.ReturnKeyLabel;
	
	import mx.collections.ArrayList;
	
	import spark.components.View;
	
	import jmcnet.mongodb.documents.MongoDocument;
	import jmcnet.mongodb.documents.MongoDocumentQuery;
	import jmcnet.mongodb.documents.MongoDocumentResponse;
	import jmcnet.mongodb.driver.EventMongoDB;
	import jmcnet.mongodb.driver.JMCNetMongoDBDriver;
	import jmcnet.mongodb.driver.MongoResponder;
	
	import views.LoginView;
	import views.todoView;

	public class MongoDBDriver
	{
		//do usunięcia
		
		internal var app:TimeKeeperv2;
		internal var driver:JMCNetMongoDBDriver;
		
		public var query:MongoDocumentQuery;
		
		public function MongoDBDriver(_app:TimeKeeperv2, _driver:JMCNetMongoDBDriver)
		{
			app = _app;
			driver = _driver;
		}
		public function logToDataBase(username:String, password:String):void {
			query = new MongoDocumentQuery();
			query.addDocumentCriteria(MongoDocument.and(
				new MongoDocument("user", username),
				new MongoDocument("password", password)));
			
			driver.queryDoc("userList", query, new MongoResponder(onResponseReceivedLogin, onErrorReceivedLogin));
		}
		
		private function onResponseReceivedLogin(responseDoc:MongoDocumentResponse, myToken:*):void {
			var loggedInDataBase:Boolean = true;
			try{
				trace(responseDoc.getDocument(0).toString());
			} catch (e:Error) {
				TimeKeeperv2.app.loginView.view.id_label_stan.text = "Wprowadzony błędny login lub hasło!";
				trace("!!!Wprowadzony błędny login lub hasło!!!");
				loggedInDataBase = false;
			} finally {
				if (loggedInDataBase){
					app.loginView.visible = false;
					app.LoginCollection= app.loginView.view.id_login.text;					
				}
			}
		}
		private function onErrorReceivedLogin(responseDoc:MongoDocumentResponse, myToken:*):void {
			trace("!!!Problem podczas logowania do bazy danych!!!");
		}
		
		public function connectToDataBase():void{
			
			driver.addEventListener(JMCNetMongoDBDriver.EVT_CONNECTOK, onConnectOK);
			driver.addEventListener(JMCNetMongoDBDriver.EVT_AUTH_ERROR, onAuthError);
			
			//driver.addEventListener(JMCNetMongoDBDriver.EVT_RUN_COMMAND, onRunCommand);
			
			driver.addEventListener(JMCNetMongoDBDriver.EVT_CLOSE_CONNECTION, onCloseConnexion);
			
			driver.connect();
		}
		protected function onConnectOK(event:EventMongoDB):void {
			if (driver.isConnecte()) {
				app.loginView.view.afterConnection(true);
			}
		}
		
		protected function onAuthError(event:EventMongoDB):void {				
			app.loginView.view.afterConnection(false);
		}
		
		//protected function onRunCommand(event:EventMongoDB):void {
		//	var response:MongoDocumentResponse = event.result as MongoDocumentResponse;
			//stan.text = response.toString();
		//}
		
		protected function onCloseConnexion(event:EventMongoDB):void
		{
			// TODO Auto-generated method stub
			//stan.text = "Koniec połączenia";
		}
		
		protected var stateArray:ArrayList;
		protected var todoViewRef:todoView;
		
		public function getToDoListMongoDB(_queryToDo:MongoDocumentQuery, _todoView:todoView):void {
			todoViewRef = _todoView;
			driver.queryDoc(app.LoginCollection, _queryToDo, new MongoResponder(TimeKeeperv2.app.mongoDBDriver.onResponseReceivedToDoList));
		}
		
		protected function onResponseReceivedToDoList(responseDoc:MongoDocumentResponse, myToken:*):void {
			//trace("+++++++++++++++++++++++++ "+responseDoc.documents.length.toString());
			stateArray  = new ArrayList();
			if(responseDoc.isOk){
				try{
					for (var i:int = 0; i < responseDoc.documents.length; i++){
						stateArray.addItem(
							new todoObject(
								responseDoc.getDocument(i).getValue("title").toString(),
								responseDoc.getDocument(i).getValue("description").toString(),
								responseDoc.getDocument(i).getValue("color").toString(),
								responseDoc.getDocument(i).getValue("data").toString(),
								responseDoc.getDocument(i).getValue("style").toString(),
								responseDoc.getDocument(i).getValue("isDone").toString(),
								responseDoc.getDocument(i).getValue("_id").toString()
							)
						)	
					}
				} catch (e:Error){
					trace("Błąd w pobieraniu listy ToDo");
				}
				todoViewRef.stateArray = stateArray;
			} else{
				trace("Błąd!!!!!!");
			}
		}
		
	}
}