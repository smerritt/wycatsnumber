var apiBase = "/api";

function fetchPath(source, destination) {
  $("#content").empty().append("Loading...");

  $.ajax({
    url: apiBase + "/path/" + source + "/" + destination,
    dataType: "json",

    error: errorCallback,
    statusCode: {
      200: function(data) { pathCallback(data, source, destination) },
      404: notFoundCallback,
      500: error500Callback,
    }
  });
}

function errorCallback(xhr, errorDescription, exception) {
  copy = $("#templates .error").clone();
  copy.find(".error_description").
    text("The network says: \"" + errorDescription + "\".");
  $("#content").empty().append(copy);
}

function error500Callback(data) {
  copy = $("#templates .error").clone();
  copy.find(".error_description").
    text("Error 500.");
  $("#content").empty().append(copy);
}

function notFoundCallback(response) {
  data = JSON.parse(response.responseText);
  var author_names = data["unknown-authors"].join(" or ");

  copy = $("#templates .unknown_authors").clone();
  copy.find(".unknown_author_names").
    text(author_names);

  $("#content").empty();
  $("#content").append(copy);
}

function displayAuthor(author) {
  copy = $("#templates .author_path_component").clone();

  copy.
    find("img.gravatar").
    attr("src", util.gravatar_url(author));

  copy.
    find("a.username").
    attr("href", util.author_url(author)).
    text(author.name);

  $("#content").append(copy);
}

function displayProject(project) {
  copy = $("#templates .project_path_component").clone();

  copy.
    find("a.project_link").
    attr("href", util.project_url(project)).
    text(project.name);

  $("#content").append(copy);
}

function displayNumber(sourceAuthor, destinationAuthor, number) {
  copy = $("#templates div.your_number").clone();

  copy.
    find("span.source").
    text(sourceAuthor);

  copy.
    find("span.destination").
    text(destinationAuthor);

  copy.
    find("span.the_number").
    text(number);

  $("#content").append(copy);
}

function displayDisconnected(source, destination) {
  copy = $("#templates div.disconnected").clone();

  copy.
    find("span.source").
    text(source);

  copy.
    find("span.destination").
    text(destination);

  $("#content").append(copy);
}

function pathCallback(data, source, destination) {
  $("#content").empty();

  if (data.length == 0) {
    displayDisconnected(source, destination);
  } else {
    displayNumber(source, destination, (data.length - 1) / 2);

    $.each(data, function(idx, elem) {
      if (elem.type == "author")
        displayAuthor(elem);
      else if (elem.type == "project")
        displayProject(elem);
    });
  }
}

function showPane(paneId) {
  $("div.pane").hide();
  $(paneId).show();

  var selectedTabId = paneId + "_tab";
  $("div.tab").removeClass("selected");
  $(selectedTabId).addClass("selected");
}

$(document).ready(function() {
  $("#path_form").submit(function(event) {
    fetchPath(
      $("#source").val().trim(),
      $("#destination").val().trim()
    );
    return false;
  });

  $("div.tab").click(function(event) {
    var myId = $(this).attr("id");
    var paneId = myId.substr(0, myId.length - 4);  // chop off the "_tab"
    showPane("#" + paneId);
  })

  $("#source").Watermark("GitHub username");

  showPane('#path_finder');
});
