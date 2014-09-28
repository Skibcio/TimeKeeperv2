package Scripts
{
	public class todoObject
	{
		[Bindable]
		public var title:String;
		[Bindable]
		public var description:String;
		[Bindable]
		public var color:String;
		[Bindable]
		public var date:String;
		[Bindable]
		public var style:String;
		[Bindable]
		public var isDone:String;
		[Bindable]
		public var id:String;
		

		
		public function todoObject(_title:String, _description:String,  _color:String, _date:String, _style:String, _isDone:String, _id:String)
		{
			title = _title;
			color = _color;
			description = _description;
			date = _date;
			style = _style;
			isDone = _isDone;
			id = _id;
		}
	}
}