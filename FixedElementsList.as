package {
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	/**
	 * TODO document class behavior...
	 */
	public class FixedElementsList extends EventDispatcher implements IList {
		
		/**
		 * Constructor.
		 */
		public function FixedElementsList(source:IList = null) {
			if (source == null) {
				source = new ArrayList();
			}
			_source = source;
			_source.addEventListener(CollectionEvent.COLLECTION_CHANGE, onsourceCollectionChange);
		}
		
		
		/* source property */
		
		/**
		 * @private
		 * Storage for source property.
		 */
		protected var _source:IList = null;
		
		/**
		 * The source wrapped list instance, containing all the elements except the fixed ones.
		 */
		public function get source():IList {
			return _source;
		}
		
		/**
		 * @private
		 */
		public function set source(value:IList):void {
			if (_source != null) {
				_source.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onsourceCollectionChange);
			}
			_source = value;
			if (_source == null) {
				_source = new ArrayList();
			}
			_source.addEventListener(CollectionEvent.COLLECTION_CHANGE, onsourceCollectionChange);
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
		}
		
		
		/* fixedElements property */
		
		/**
		 * @private
		 * Storage for fixedElements property.
		 */
		protected var _fixedElements:Array = [];
		
		/**
		 * The fixed elements to be added to the wrapped list. 
		 */
		[Bindable]
		public function get fixedElements():Array {
			return _fixedElements;
		}
		
		/**
		 * @private
		 */
		public function set fixedElements(value:Array):void {
			if (value == null) {
				throw new ArgumentError("Fixed elements cannot be null.");
			}
			_fixedElements = value;
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
		}
		
		
		/* event handlers */
		
		/**
		 * @private
		 */
		protected function onsourceCollectionChange(event:CollectionEvent):void {
			dispatchEvent(new CollectionEvent(event.type, event.bubbles, event.cancelable,
				event.kind, event.location + _fixedElements.length, event.location + _fixedElements.length, event.items));
		}
		
		
		/* implementation of mx.collections.IList */
		
		/**
		 * @copy mx.collections.IList#length
		 */
		[Bindable(event="collectionChange")]
		public function get length():int {
			return _source.length + _fixedElements.length;
		}
		
		/**
		 * @copy mx.collections.IList#addItem
		 */
		public function addItem(item:Object):void {
			_source.addItem(item);
		}
		
		/**
		 * @copy mx.collections.IList#addItemAt
		 */
		public function addItemAt(item:Object, index:int):void {
			// fixed items are always presented on top, so throw an error if index is not valid
			if (index < _fixedElements.length) {
				throw new ArgumentError("Index out of bound: cannot insert element in the fixed elements section.");
			}
			_source.addItemAt(item, index - _fixedElements.length);
		}
		
		/**
		 * @copy mx.collections.IList#getItemAt
		 */
		public function getItemAt(index:int, prefetch:int=0):Object {
			if (index < _fixedElements.length) {
				return _fixedElements[index];
			} else {
				return _source.getItemAt(index - _fixedElements.length, prefetch);
			}
		}
		
		/**
		 * @copy mx.collections.IList#getItemIndex
		 */
		public function getItemIndex(item:Object):int {
			// priority to non-fixed items
			var index:int = _source.getItemIndex(item);
			if (index >= 0) {
				return index;
			} else {
				return _fixedElements.indexOf(item);
			}
		}
		
		/**
		 * @copy mx.collections.IList#itemUpdated
		 */
		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void {
			// fixed items are supposed to be fixed, apply only to wrapped list
			_source.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * @copy mx.collections.IList#removeAll 
		 */
		public function removeAll():void {
			// fixed items are supposed to be fixed, apply only to wrapped list
			_source.removeAll();
		}
		
		/**
		 * @copy mx.collections.IList#removeItemAt 
		 */
		public function removeItemAt(index:int):Object {
			if (index < _fixedElements.length) {
				throw new ArgumentError("Index out of bound: cannot remove elements in the fixed elements section.");
			}
			return _source.removeItemAt(index - _fixedElements.length);
		}
		
		/**
		 * @copy mx.collections.IList#setItemAt 
		 */
		public function setItemAt(item:Object, index:int):Object {
			if (index < _fixedElements.length) {
				throw new ArgumentError("Index out of bound: cannot updated elements in the fixed elements section.");
			}
			return _source.setItemAt(item, index - _fixedElements.length);
		}
		
		/**
		 * @copy mx.collections.IList#toArray 
		 */
		public function toArray():Array {
			return _fixedElements.toArray().concat(_source.toArray());
		}
		
	}
	
}