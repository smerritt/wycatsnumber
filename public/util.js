if (typeof(util) == "undefined") {
  util = {};
}

util.author_url = function(author) {
  return "https://github.com/" + author.name;
}

util.gravatar_url = function(author) {
  return "http://www.gravatar.com/avatar/" + author.gravatar_id;
}

util.project_url = function(project) {
  return "https://github.com/" + project.name;
}

