:- use_module(library(http/json)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_server)).

% Define HTTP Handlers
:- http_handler('/query', handle_query, []).
:- http_handler('/favicon.ico', handle_favicon, []). % Avoid 404 for favicon requests

% CORS Headers
add_cors_headers :-
    format('Access-Control-Allow-Origin: *~n'),
    format('Access-Control-Allow-Methods: POST, GET, OPTIONS~n'),
    format('Access-Control-Allow-Headers: Content-Type~n').

% Handle OPTIONS preflight requests
handle_options(Request) :-
    memberchk(method(options), Request), 
    add_cors_headers,
    format('Content-type: application/json~n~n'),
    reply_json_dict(_{status: "OK"}).

% Handle the /query route
handle_query(Request) :-
    ( memberchk(method(options), Request) -> handle_options(Request)
    ; add_cors_headers,
      % Parse JSON input
      http_read_json_dict(Request, QueryDict),
      ( get_dict(query, QueryDict, Sentence) ->
            process_sentence_json(Sentence, Results),
            reply_json_dict(_{results: Results})
        ; reply_json_dict(_{error: "Missing 'query' field in request."}, [status(400)])
      )
    ).

% Handle /favicon.ico requests (to avoid 404 errors)
handle_favicon(_) :-
    add_cors_headers,
    reply_json_dict(_{status: "No favicon available"}, [status(204)]).

% Process a sentence and infer results
process_sentence_json(Sentence, Results) :-
    string_lower(Sentence, LowerCaseSentence),
    split_string(LowerCaseSentence, " ", "", Words),
    ( find_task(Words, Task) ->
        ( find_parameters(Words, Task, Parameters) ->
            collect_methods(Task, Parameters, Results)
        ; collect_all_methods(Task, Results)
        )
    ; Results = [_{error: "No methods available for this task."}]
    ).

% Find task, parameters, and methods
find_task(Words, Task) :- member(Word, Words), keyword_task(Word, Task), !.
find_parameters(Words, Task, Parameters) :-
    parameter(Task, Parameter, ValidValues),
    findall(Value, (member(Word, Words), keyword_value(Word, Parameter, Value), member(Value, ValidValues)), Parameters),
    Parameters \= [].
collect_methods(Task, Values, Results) :-
    findall(_{method: MethodName, description: Description}, (member(Value, Values), method(Task, Value, MethodName, Description)), Results).
collect_all_methods(Task, Results) :-
    findall(_{method: MethodName, description: Description}, method(Task, _, MethodName, Description), Results).

% Start the server
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Knowledge base for Java methods and their descriptions

% Task facts
task(sorting).
task(searching).
task(file_handling).
task(database_interaction).
task(string_manipulation).
task(data_structure_operations).
task(multithreading).
task(exception_handling).
task(networking).
task(generics).
task(parallel_processing).
task(logging).
task(conversion).

% Parameters for narrowing down options
parameter(sorting, order, [ascending, descending, asend, desend, alphabetical, reverse_alphabetical, numeric, reverse_numeric]).
parameter(searching, data_structure, [array, list, hashmap, tree, graph, set]).
parameter(file_handling, action, [read, write, append, delete, copy, move, rename]).
parameter(database_interaction, operation, [connect, query, update, delete, insert, join]).
parameter(string_manipulation, operation, [concatenate, replace, split, substring, to_uppercase, to_lowercase, trim, reverse]).
parameter(data_structure_operations, structure, [stack, queue, linkedlist, hashmap, arraylist, priority_queue, deque]).
parameter(multithreading, use_case, [runnable, callable, threadpool, synchronize, forkjoin, deadlock, atomic_operations]).
parameter(exception_handling, type, [try_catch, throws, finally, custom_exception]).
parameter(networking, protocol, [http, https, tcp, udp, ftp]).
parameter(generics, type, [wildcards, bounded, unbounded]).
parameter(parallel_processing, operation, [map_reduce, parallel_stream, completable_future]).
parameter(logging, level, [info, debug, error, warn, fatal]).
parameter(conversion, type, [string_to_int, int_to_string, object_to_json, json_to_object]).

% Methods for sorting
method(sorting, ascending, "Arrays.sort(array)",
       "Sort an array in ascending order using Java Arrays.sort.").
method(sorting, descending, "Arrays.sort(array, Collections.reverseOrder())",
       "Sort an array in descending order using Java Arrays.sort with a custom comparator.").
method(sorting, alphabetical, "Collections.sort(list)",
       "Sort a list in alphabetical order using Java Collections.sort.").
method(sorting, reverse_alphabetical, "Collections.sort(list, Collections.reverseOrder())",
       "Sort a list in reverse alphabetical order.").
method(sorting, numeric, "Arrays.sort(numbers)",
       "Sort an array of numbers in ascending order.").
method(sorting, reverse_numeric, "Arrays.sort(numbers, Comparator.reverseOrder())",
       "Sort an array of numbers in descending order.").

% Methods for searching
method(searching, array, "Arrays.binarySearch(array, key)",
       "Search for a key in a sorted array using Java's binary search.").
method(searching, list, "Collections.binarySearch(list, key)",
       "Search for a key in a sorted list using Java's binary search.").
method(searching, hashmap, "map.containsKey(key)",
       "Check if a HashMap contains a specific key.").
method(searching, tree, "tree.contains(key)",
       "Check if a binary search tree contains a specific key.").
method(searching, graph, "graph.search(startNode, targetNode)",
       "Perform a search in a graph from a start node to a target node.").
method(searching, set, "set.contains(element)",
       "Check if a Set contains a specific element.").

% Methods for file handling
method(file_handling, read, "BufferedReader reader = new BufferedReader(new FileReader(file))",
       "Read a file line by line using Java BufferedReader.").
method(file_handling, write, "BufferedWriter writer = new BufferedWriter(new FileWriter(file))",
       "Write to a file using Java BufferedWriter.").
method(file_handling, append, "Files.write(Paths.get(file), content, StandardOpenOption.APPEND)",
       "Append content to a file using Java NIO.").
method(file_handling, delete, "Files.delete(Paths.get(file))",
       "Delete a file using Java NIO.").
method(file_handling, copy, "Files.copy(sourcePath, targetPath)",
       "Copy a file from one location to another using Java NIO.").
method(file_handling, move, "Files.move(sourcePath, targetPath)",
       "Move a file from one location to another using Java NIO.").
method(file_handling, rename, "Files.move(oldPath, newPath)",
       "Rename a file using Java NIO.").

% Methods for database interaction
method(database_interaction, connect, "DriverManager.getConnection(url, username, password)",
       "Establish a connection to a database using Java DriverManager.").
method(database_interaction, query, "PreparedStatement.executeQuery(query)",
       "Execute a query and retrieve results from a database using PreparedStatement.").
method(database_interaction, update, "PreparedStatement.executeUpdate(query)",
       "Update data in a database using PreparedStatement.").
method(database_interaction, delete, "PreparedStatement.execute(query)",
       "Delete data from a database using PreparedStatement.").
method(database_interaction, insert, "PreparedStatement.executeUpdate(insertQuery)",
       "Insert data into a database using PreparedStatement.").
method(database_interaction, join, "SELECT * FROM table1 JOIN table2 ON condition",
       "Perform a join operation between two tables in SQL.").

% Methods for string manipulation
method(string_manipulation, concatenate, "String result = str1 + str2",
       "Concatenate two strings using the '+' operator in Java.").
method(string_manipulation, replace, "String result = str.replace(oldChar, newChar)",
       "Replace characters in a string using the replace method in Java.").
method(string_manipulation, split, "String[] parts = str.split(delimiter)",
       "Split a string into an array using a delimiter.").
method(string_manipulation, substring, "String sub = str.substring(start, end)",
       "Extract a substring from a string using the substring method.").
method(string_manipulation, to_uppercase, "String upper = str.toUpperCase()",
       "Convert a string to uppercase using Java.").
method(string_manipulation, to_lowercase, "String lower = str.toLowerCase()",
       "Convert a string to lowercase using Java.").
method(string_manipulation, trim, "String trimmed = str.trim()",
       "Remove leading and trailing spaces from a string using the trim method.").
method(string_manipulation, reverse, "String reversed = new StringBuilder(str).reverse().toString()",
       "Reverse a string using StringBuilder in Java.").

% Methods for data structure operations
method(data_structure_operations, stack, "stack.push(element), stack.pop()",
       "Perform push and pop operations on a stack.").
method(data_structure_operations, queue, "queue.offer(element), queue.poll()",
       "Perform enqueue and dequeue operations on a queue.").
method(data_structure_operations, linkedlist, "list.add(element), list.remove(index)",
       "Perform operations on a LinkedList.").
method(data_structure_operations, hashmap, "map.put(key, value), map.get(key)",
       "Perform put and get operations on a HashMap.").
method(data_structure_operations, arraylist, "list.add(element), list.get(index)",
       "Perform add and get operations on an ArrayList.").
method(data_structure_operations, priority_queue, "queue.add(element), queue.poll()",
       "Perform operations on a PriorityQueue.").
method(data_structure_operations, deque, "deque.addFirst(element), deque.removeLast()",
       "Perform operations on a Deque.").

% Methods for multithreading
method(multithreading, runnable, "Thread thread = new Thread(new Runnable() {...})",
       "Create a thread using the Runnable interface in Java.").
method(multithreading, callable, "Future<Integer> result = executor.submit(new Callable<Integer>() {...})",
       "Use the Callable interface with an ExecutorService.").
method(multithreading, threadpool, "ExecutorService executor = Executors.newFixedThreadPool(n)",
       "Create a thread pool using ExecutorService.").
method(multithreading, synchronize, "synchronized(object) { // critical section }",
       "Synchronize a block of code to prevent thread interference.").
method(multithreading, forkjoin, "ForkJoinPool pool = new ForkJoinPool(); pool.invoke(task)",
       "Use ForkJoinPool for parallel tasks.").
method(multithreading, atomic_operations, "AtomicInteger atomicInt = new AtomicInteger(0)",
       "Perform atomic operations using Java's AtomicInteger.").
% Methods for exception handling
method(exception_handling, try_catch, "try {
  // Code that may throw an exception
} catch (Exception e) {
  e.printStackTrace();
}",
       "Handle exceptions in Java using try-catch blocks.").
method(exception_handling, throws, "public void method() throws Exception",
       "Declare exceptions that a method can throw using the 'throws' keyword.").
method(exception_handling, finally, "try {
  // Code
} finally {
  // Cleanup code
}",
       "Use a 'finally' block for cleanup code that always executes.").
method(exception_handling, custom_exception, "class MyException extends Exception { }",
       "Define and use custom exceptions in Java.").

% Methods for networking
method(networking, http, "HttpURLConnection connection = (HttpURLConnection) url.openConnection()",
       "Establish an HTTP connection using Java's HttpURLConnection.").
method(networking, https, "HttpsURLConnection connection = (HttpsURLConnection) url.openConnection()",
       "Establish an HTTPS connection using Java's HttpsURLConnection.").
method(networking, tcp, "Socket socket = new Socket(serverAddress, port)",
       "Establish a TCP connection using Java's Socket class.").
method(networking, udp, "DatagramSocket socket = new DatagramSocket()",
       "Establish a UDP connection using Java's DatagramSocket.").
method(networking, ftp, "FTPClient ftp = new FTPClient(); ftp.connect(server)",
       "Connect to an FTP server using Java's FTPClient.").

% Methods for generics
method(generics, wildcards, "List<? extends Number> list",
       "Use wildcards in generics for upper-bounded types.").
method(generics, bounded, "class Box<T extends Number> { }",
       "Define a generic class with bounded type parameters.").
method(generics, unbounded, "List<?> list",
       "Use unbounded wildcards in generics.").

% Methods for parallel processing
method(parallel_processing, map_reduce, "mapReduceStream.reduce(identity, accumulator)",
       "Perform map-reduce operations using Java Streams.").
method(parallel_processing, parallel_stream, "list.parallelStream().forEach(action)",
       "Use parallel streams for concurrent data processing in Java.").
method(parallel_processing, completable_future, "CompletableFuture.supplyAsync(() -> compute())",
       "Execute asynchronous tasks using Java's CompletableFuture.").

% Methods for logging
method(logging, info, "logger.info(message)",
       "Log informational messages using Java's Logger.").
method(logging, debug, "logger.debug(message)",
       "Log debugging messages using Java's Logger.").
method(logging, error, "logger.error(message)",
       "Log error messages using Java's Logger.").
method(logging, warn, "logger.warn(message)",
       "Log warning messages using Java's Logger.").
method(logging, fatal, "logger.fatal(message)",
       "Log fatal error messages using Java's Logger.").

% Methods for conversion
method(conversion, string_to_int, "int number = Integer.parseInt(string)",
       "Convert a string to an integer using Integer.parseInt.").
method(conversion, int_to_string, "String str = Integer.toString(number)",
       "Convert an integer to a string using Integer.toString.").
method(conversion, object_to_json, "String json = new Gson().toJson(object)",
       "Convert a Java object to JSON using Gson.").
method(conversion, json_to_object, "Object obj = new Gson().fromJson(json, ClassType.class)",
       "Convert a JSON string to a Java object using Gson.").

% Keyword mappings
keyword_task("sort", sorting).
keyword_task("arrange", sorting).
keyword_task("order", sorting).
keyword_task("sequence", sorting).

keyword_task("search", searching).
keyword_task("find", searching).
keyword_task("locate", searching).
keyword_task("lookup", searching).

keyword_task("file", file_handling).
keyword_task("read", file_handling).
keyword_task("write", file_handling).
keyword_task("append", file_handling).
keyword_task("delete", file_handling).
keyword_task("copy", file_handling).
keyword_task("move", file_handling).
keyword_task("rename", file_handling).

keyword_task("database", database_interaction).
keyword_task("connect", database_interaction).
keyword_task("query", database_interaction).
keyword_task("insert", database_interaction).
keyword_task("update", database_interaction).
keyword_task("delete", database_interaction).
keyword_task("join", database_interaction).

keyword_task("concatenate", string_manipulation).
keyword_task("replace", string_manipulation).
keyword_task("split", string_manipulation).
keyword_task("substring", string_manipulation).
keyword_task("uppercase", string_manipulation).
keyword_task("lowercase", string_manipulation).
keyword_task("trim", string_manipulation).
keyword_task("reverse", string_manipulation).
keyword_task("string", string_manipulation).
keyword_task("text", string_manipulation).

keyword_task("data_structure", data_structure_operations).
keyword_task("stack", data_structure_operations).
keyword_task("queue", data_structure_operations).
keyword_task("hashmap", data_structure_operations).
keyword_task("linkedlist", data_structure_operations).
keyword_task("arraylist", data_structure_operations).
keyword_task("deque", data_structure_operations).
keyword_task("priority_queue", data_structure_operations).

keyword_task("thread", multithreading).
keyword_task("parallel", multithreading).
keyword_task("concurrent", multithreading).
keyword_task("synchronize", multithreading).
keyword_task("forkjoin", multithreading).
keyword_task("atomic", multithreading).
keyword_task("threadpool", multithreading).

keyword_task("try_catch", exception_handling).
keyword_task("throws", exception_handling).
keyword_task("finally", exception_handling).
keyword_task("custom_exception", exception_handling).

keyword_task("http", networking).
keyword_task("https", networking).
keyword_task("tcp", networking).
keyword_task("udp", networking).
keyword_task("ftp", networking).

keyword_task("wildcards", generics).
keyword_task("bounded", generics).
keyword_task("unbounded", generics).

keyword_task("map_reduce", parallel_processing).
keyword_task("parallel_stream", parallel_processing).
keyword_task("completable_future", parallel_processing).

keyword_task("info", logging).
keyword_task("debug", logging).
keyword_task("error", logging).
keyword_task("warn", logging).
keyword_task("fatal", logging).

keyword_task("string_to_int", conversion).
keyword_task("int_to_string", conversion).
keyword_task("object_to_json", conversion).
keyword_task("json_to_object", conversion).

%************* keyword_value

% Sorting
keyword_value("ascending", order, ascending).
keyword_value("descending", order, descending).
keyword_value("asend", order, ascending).
keyword_value("desend", order, descending).
keyword_value("alphabetical", order, alphabetical).
keyword_value("reverse_alphabetical", order, reverse_alphabetical).
keyword_value("numeric", order, numeric).
keyword_value("reverse_numeric", order, reverse_numeric).

% Searching
keyword_value("array", data_structure, array).
keyword_value("list", data_structure, list).
keyword_value("hashmap", data_structure, hashmap).
keyword_value("tree", data_structure, tree).
keyword_value("graph", data_structure, graph).
keyword_value("set", data_structure, set).

% File Handling
keyword_value("read", action, read).
keyword_value("write", action, write).
keyword_value("append", action, append).
keyword_value("delete", action, delete).
keyword_value("copy", action, copy).
keyword_value("move", action, move).
keyword_value("rename", action, rename).

% Database Interaction
keyword_value("connect", operation, connect).
keyword_value("query", operation, query).
keyword_value("update", operation, update).
keyword_value("delete", operation, delete).
keyword_value("insert", operation, insert).
keyword_value("join", operation, join).

% String Manipulation
keyword_value("concatenate", operation, concatenate).
keyword_value("replace", operation, replace).
keyword_value("split", operation, split).
keyword_value("substring", operation, substring).
keyword_value("uppercase", operation, to_uppercase).
keyword_value("lowercase", operation, to_lowercase).
keyword_value("trim", operation, trim).
keyword_value("reverse", operation, reverse).

% Data Structure Operations
keyword_value("stack", structure, stack).
keyword_value("queue", structure, queue).
keyword_value("hashmap", structure, hashmap).
keyword_value("linkedlist", structure, linkedlist).
keyword_value("arraylist", structure, arraylist).
keyword_value("priority_queue", structure, priority_queue).
keyword_value("deque", structure, deque).

% Multithreading
keyword_value("runnable", use_case, runnable).
keyword_value("callable", use_case, callable).
keyword_value("threadpool", use_case, threadpool).
keyword_value("synchronize", use_case, synchronize).
keyword_value("forkjoin", use_case, forkjoin).
keyword_value("atomic", use_case, atomic_operations).
keyword_value("parallel", use_case, parallel_processing).
% Exception Handling
keyword_value("try_catch", type, try_catch).
keyword_value("throws", type, throws).
keyword_value("finally", type, finally).
keyword_value("custom_exception", type, custom_exception).

% Networking
keyword_value("http", protocol, http).
keyword_value("https", protocol, https).
keyword_value("tcp", protocol, tcp).
keyword_value("udp", protocol, udp).
keyword_value("ftp", protocol, ftp).

% Generics
keyword_value("wildcards", type, wildcards).
keyword_value("bounded", type, bounded).
keyword_value("unbounded", type, unbounded).

% Parallel Processing
keyword_value("map_reduce", operation, map_reduce).
keyword_value("parallel_stream", operation, parallel_stream).
keyword_value("completable_future", operation, completable_future).

% Logging
keyword_value("info", level, info).
keyword_value("debug", level, debug).
keyword_value("error", level, error).
keyword_value("warn", level, warn).
keyword_value("fatal", level, fatal).

% Conversion
keyword_value("string_to_int", type, string_to_int).
keyword_value("int_to_string", type, int_to_string).
keyword_value("object_to_json", type, object_to_json).
keyword_value("json_to_object", type, json_to_object).
%******** process *********


