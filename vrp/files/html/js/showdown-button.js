(function (extension) {
  'use strict';

    extension(showdown);

}(function (showdown) {
  'use strict';

  showdown.extension('button', function() {
    'use strict';

    return {
      type: 'lang',
      filter: function (text, converter, options) {


        while (true) {
          var reg = /\[@\[button\]\(([a-zA-Z0-9 ]{0,})\)\(([a-zA-Z0-9?=&-.]{0,})\)\]/;

          var match = reg.exec(text)
          
          if(match === null)
            break;
          
          text = text.replace(match[0], "<button onclick=\"var request = new XMLHttpRequest(); request.open('GET', 'http://mta/local/ajax?" + match[2] + "', true); request.send();\">" + match[1] + "</button>")
        }
        return text;
      }
    };
  });
}));
