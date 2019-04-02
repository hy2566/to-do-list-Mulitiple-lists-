<todo-realtime>
	<div class="row">
		<!-- This is side bar -->
	  <div id="side" class="col-3">
		  <form>
			  <button disabled = {!listText} onclick={ addNewList }>Add new list</button>
				<input ref="listText" type="text" onkeyup={ editListName }>
		  </form>
		  <div id="listsnames">
				<ul>
					<li each={ todolist in lists } onclick={ chooseList } >
						<label>
							{ todolist.name }
						</label>
					</li>
				</ul>
		  </div>
	  </div>
		<!-- This is the main list -->
	  <div id="main" class= "col-9">
		<h1>{currentListName}</h1>
		<ul>
			<li each={ todo in items.filter(whatShow) }>
				<label class={ completed: todo.done }>
					<input type="checkbox" checked={ todo.done } onclick={ parent.toggle }>
					{ todo.title }
				</label>
			</li>
		</ul>

		<form onsubmit={ add }>
			<input ref="input" onkeyup={ edit }>
			<button disabled={ !text }>Add #{ items.filter(whatShow).length + 1 }</button>

			<button type="button" disabled={ items.filter(onlyDone).length == 0 } onclick={ removeAllDone }>
				X{ items.filter(onlyDone).length }
			</button>
		</form>
	</div>
  </div>


	<!-- this script tag is optional -->
	<script>
		this.title = opts.title || "DEFAULT TITLE";
		this.lists = opts.lists || [];
		this.items = opts.items || [];
		this.mappings = opts.mappings || {};
		this.currentListName = '';

		edit(event) {
			this.text = event.target.value;
		}

		editListName(event) {
			this.listText = event.target.value;
		}

    showList(listname) {
			this.currentListName = listname
			docId = this.mappings[listname]

			database.collection('todoList').doc(docId).collection('list').onSnapshot(snapshot => {
				this.items = snapshot.docs.map(doc => doc.data());
				this.update();
				console.log(this.items)
			});
		}

		chooseList(event) {
			listname = event.target.innerHTML.trim()
			this.showList(listname)
		}




		refreshList(docId) {
			database.collection('todoList').doc(docId).collection('list').onSnapshot(snapshot => {
				this.items = snapshot.docs.map(doc => doc.data());
				this.update();
				console.log(this.items)
			});
		}

    addNewList(event) {
			if (this.listText) {
				let collectionRef = database.collection('todoList');
				let docRef = collectionRef.doc();
				let id = docRef.id;
				// DATABASE WRITE
				collectionRef.doc(id).set({
					name: this.listText,
					id: id
				});
				this.listText = this.refs.listText.value='';
				//this.updateList();
			}
		}

		deleteList(event) {

		}

		add(event) {
			if (this.text) {
				docId = this.mappings[this.currentListName]
				// DATABASE WRITE - Preparation
				let collectionRef = database.collection('todoList').doc(docId).collection('list');
				let docRef = collectionRef.doc();
				let id = docRef.id;
				collectionRef.doc(id).set({
					title: this.text,
					done: false,
					id: id
				});
				this.text = this.refs.input.value = '';
				this.refreshList(docId)
			}
			event.preventDefault();
		}

		removeAllDone(event) {
			let doneItems = this.items.filter(todo => todo.done);
			docId = this.mappings[this.currentListName]
			for (doneTodo of doneItems) {
				// DATABASE DELETE
				console.log(doneTodo)
				database.collection('todoList').doc(docId).collection('list').doc(doneTodo.id).delete();
			}
		}

		toggle(event) {
			let item = event.item.todo;
			item.done = !item.done;
			return true;
		}

		// FILTER FUNCTIONS ----------------------------------------
    fromName(item, name) {
			return item.name==name;
		}

		whatShow(item) {
			return !item.hidden;
		}

		onlyDone(item) {
			return item.done;
		}

		// LIFECYCLE EVENTS ---------------------------------------

    updateList(){
			database.collection('todoList').onSnapshot(snapshot => {
				this.lists = snapshot.docs.map(doc => doc.data());
				this.mappings = {}
				this.lists.forEach((key, i) => this.mappings[key.name] = key.id);
				this.update();
				this.showList(this.lists[0].name)
			});
		}

    this.updateList();

		/*
		this.on('mount', () => {
			// DATABASE READ LIVE
			stopListeningList = database.collection('todoList').onSnapshot(snapshot => {
				this.listIds = snapshot.docs.map(doc => doc.id );
				this.lists = snapshot.docs.map(doc => doc.data());
				this.mappings = {}
				this.lists.forEach((key, i) => this.mappings[key.name] = this.listIds[i]);
				this.update();
			});

			stopListening = database.collection('todos-live').onSnapshot(snapshot => {
				this.items = snapshot.docs.map(doc => doc.data());
				this.update();
			});
		});

		this.on('unmount', () => {
			stopListening();
			stopListeningList();
		});*/
	</script>

</todo-realtime>
