if (typeof(util) == "undefined") {
  util = {};
}

util.gravatar = function(githubUser) {
  return $("<a></a>").
    attr("href", "?username=" + githubUser.name).
    append($("<img>").
           attr("src", 
                'http://www.gravatar.com/avatar/' + githubUser.gravatar_id).
           attr("alt", githubUser.name).
           attr("title", githubUser.name));;
}

util.userWithGravatar = function(githubUser) {
  return $("<div></div>").
    addClass("user_with_picture").
    append($("<div></div>").
           addClass("gravatar").
           append(util.gravatar(githubUser))).
    append($("<div></div>").
           addClass("username").
           append($("<a></a>").
                  addClass("username").
                  attr("href", "https://github.com/" + githubUser.name).
                  text(githubUser.name)));

}
