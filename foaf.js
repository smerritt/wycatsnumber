var apiBase = "http://localhost:4000";

function fetchFriendData(authorName) {
  $.ajax({
    url: apiBase + "/friends/" + authorName,
    dataType: "jsonp",
    success: function(data) { friendCallback(data, authorName) }
  });
}

function fetchFoafData(authorName) {
  $.ajax({
    url: apiBase + "/foaf/" + authorName,
    dataType: "jsonp",
    success: function(data) { foafCallback(data, authorName) }
  });
}

function gravatar(github_user) {
  return $("<a></a>").
    attr("href", "?username=" + github_user.name).
    append($("<img>").
           attr("src", 
                'http://www.gravatar.com/avatar/' + github_user.gravatar_id).
           attr("alt", github_user.name).
           attr("title", github_user.name));;
}

function displayUser(github_user, where) {
  var newEntry = $("<div></div>").
    addClass("result").
    append($("<div></div>").
           addClass("gravatar").
           append(gravatar(github_user))).
    append($("<div></div>").
           addClass("username").
           append($("<a></a>").
                  addClass("username").
                  attr("href", "https://github.com/" + github_user.name).
                  text(github_user.name).
                  click(function(e) {
                    fetchFoafData(github_user.name);
                  })));

  $(where).append(newEntry);
}

function foafCallback(data, username) {
  $("#foafs").
    empty().
    append($("<h1></h1>").
           text("Friends of friends of " + username));

  $.each(data, function(i, x) {
    if (i < 100)
      displayUser(x, '#foafs');
  });
}

function friendCallback(data, username) {
  $("#friends").
    empty().
    append($("<h1></h1>").
           text("Friends of " + username));

  $.each(data, function(i, x) {
    displayUser(x, '#friends');
  });
}

function maybeLoadFromQueryString() {
  var username_idx = document.location.href.indexOf("username=");
  var username = "";
  if (username_idx >= 0) {
    var username_and_crud = document.location.href.substring(username_idx + 9);
    end_of_crud_idx = username_and_crud.indexOf("&");
    if (end_of_crud_idx >= 0)
      username = username_and_crud.substring(0, end_of_crud_idx);
    else
      username = username_and_crud;  // no crud in this case
  }

  if (username.length > 0) {
    $("#foaf_form").hide();
    fetchFriendData(username);
    fetchFoafData(username);
  }
}

$(document).ready(function() {
  $("#foaf_form").submit(function(event) {
    fetchFoafData($("#username").val());
    return false;
  });

  maybeLoadFromQueryString();
})
