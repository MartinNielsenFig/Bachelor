//Directive for capturing enter key in angular
//Found at: http://stackoverflow.com/questions/28851893/angularjs-textaera-enter-key-submit-form-with-autocomplete
app.directive('ngEnter', function () {
    return function (scope, element, attrs) {
        element.bind("keydown", function (e) {
            //Check that enter key is hit and that shift key is not(shift to add row to message)
            if (e.which === 13 && !window.event.shiftKey) {
                scope.$apply(function () {
                    scope.$eval(attrs.ngEnter, { 'e': e });
                });
                e.preventDefault();
            }
        });
    };
});