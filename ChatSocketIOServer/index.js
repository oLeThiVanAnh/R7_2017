var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var userList = {};
var socketList = {};

http.listen(9999, function(){
  console.log('Listening on *:9999');
});


io.on('connection', function(clientSocket){
    console.log('a new user connected');
    userList[clientSocket.id] = clientSocket.id
    socketList[clientSocket.id] = clientSocket

    clientSocket.on('disconnect', function(){
        console.log('user disconnected');
        delete userList[clientSocket.id]
        delete socketList[clientSocket.id]
    });
                    
    clientSocket.on('newChatMessage', function(toUserID, message){
        if (socketList.hasOwnProperty(toUserID)) {
            socketList[toUserID].emit('newChatMessage', toUserID, message);
        }
    });

    clientSocket.on("updateNickname", function(clientNickname) {
        var message = "User: " + clientNickname + " was connected.";
        console.log(message);
        userList[clientSocket.id] = clientNickname
        io.emit("updateFriendList", userList);
    });

});
