public class Queue {

	public class EmptyQueueException extends Exception {}

	private List<Object> elements;
	
	public Queue() {
		elements = new List<Object>();
	}

	public Queue(List<Object> objList) {
		this();
		for(Object obj: objList) {
			enqueue(obj);
		}
	}	

	public Queue enqueue(Object obj) {
		elements.add(obj);
		return this;
	}

	public Object dequeue() {
		if(!elements.isEmpty()) {
			return elements.remove(0);
		} else {
			throw new EmptyQueueException();
		}
	}

	public Boolean isEmpty() {
		return elements.isEmpty();
	}

	public class SObj {
		private List<SObject> elements;
		
		public SObj() {
			elements = new List<SObject>();
		}

		public SObj(List<SObject> objList) {
			this();
			for(SObject obj: objList) {
				enqueue(obj);
			}
		}	

		public SObj enqueue(SObject obj) {
			elements.add(obj);
			return this;
		}

		public SObject dequeue() {
			if(!elements.isEmpty()) {
				return elements.remove(0);
			} else {
				throw new EmptyQueueException();
			}
		}

		public Boolean isEmpty() {
			return elements.isEmpty();
		}

	}
}