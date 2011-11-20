# runner: jQuery plugin

A simple runner/stopwatch jQuery plugin for counting time up and down.

## Installation

Include script *after* the jQuery library:

```html
<script src="jquery.min.js" type="text/javascript"></script>
<script src="jquery.runner.js" type="text/javascript"></script>
```


## Usage

#### First you need a container element where we can input the value of the runner:

```html
<span id="runner"></span>
```

Note that this allows you to use any kind of element (h1, div, span, td, li, input, etc), and gives you an easy way to style it any way you want. Just remember that everything inside the container will be replaced with the formatted time.

#### Then you initialize the runner to that element:

```javascript
$('#runner').runner();
```

#### After that you can start the runner from a button click or some other event:

```javascript
$('#myButton').click(function() {
    $('#runner').runner('start');
});
```


**More examples below**

## Methods

By default, when the runner method is invoked, the script will initialize itself to the selected element. If no options are given, the default values are used.

```javascript
$('#runner').runner();
```



`start` - Start the runner. If runner is not already initialized, it will first initialize and then start itself. Fires `runnerStarted` event.

```javascript
$('#runner').runner('start');
```



`stop` - Stop the runner. Fires `runnerStopped` event.

```javascript
$('#runner').runner('stop');
```



`lap` - Take a lap time ("snapshot" of the current time) and return it as a formatted string. Fires `runnerLap` event.

```javascript
alert("Current lap time: " + $('#runner').runner('lap'));
```



`toggle` - Toggle between `start` and `stop`.

```javascript
$('#runner').runner('toggle');
```



`reset` - Resets the time and settings to the original (initial) values. **Note that if the runner is running when invoking this method, this does not stop the runner, it just resets the time back to where it started and continues from there.**

```javascript
$('#runner').runner('reset');
```



`info` - Returns a JavaScript object with information about the current status of the runner.

```javascript
$('#runner').runner('info');
```


## Options

You can alter the behavior by passing options object to the initialization.

#### Here's a list of options you can use:

* `autostart` - (boolean) If set to true, the runner will be started automatically after the initialization. Defaults to false.

* `countdown` - (boolean) If set to true, the time will run down instead of up (default). **Note that if you set this to true, you should also set `startAt` option, otherwise the time goes to negative.**

* `startAt` - (integer) Time in milliseconds from which the runner should start running. Defaults to 0. This works with both counting up and down, as long as the value is within the current run direction.

* `stopAt` - (integer) Time in milliseconds at which the runner should stop running and invoke the `runnerStopped` event. Default is null (don't stop).

* `milliseconds` - (boolean) If set to false, the default formatter will omit the milliseconds from displaying. Defaults to true (show milliseconds). **Note that if you use a custom formatter, this option will not affect the first value of that custom formatter function. This option, however, is passed in as third argument.**

* `format` - (function) A custom format function to replace the default time formatting. By default this is not set. Takes in two arguments: first one is the current time value in milliseconds, the second one is the original formatter function reference, and the third one is the value of the `milliseconds` option. This function should return a string or a number.

* `interval` - (integer) Time in milliseconds how often we update the current time. Defaults to 20ms. **Note that if you use the `stopAt` option, the accuracy of the stop time will be affected by this. Also note that it is not recommended to use this option, unless you know what you're doing.**


## Events

#### There are currently 3 events that gets fired:

* `runnerStarted` - This event gets fired when the `start` method is invoked.

* `runnerStopped` - This event gets fired when the `stop` method is invoked. Note that this event is also fired when the runner reaches the `stopAt` value.

* `runnerLap` - This event gets fired when the `lap` method is invoked.


Each of these events will pass the result of the `info` method as an argument in the event call. See examples for usage.

## Examples

#### Initialize a count down runner that starts from 60 seconds, and start it automatically:

```javascript
$('#runner').runner({
    autostart: true,
    countdown: true,
    startAt: 60000 // alternatively you could just write: 60*1000
});
```


#### Initialize a count up runner that stops after 2 minutes:

```javascript
$('#runner').runner({
    stopAt: 120000 // 2(min) * 60(sec) * 1000(ms) = 120000
});
```


#### Initialize a count down runner that starts from 30 seconds, updates the value once every second and doesn't show milliseconds:

```javascript
$('#runner').runner({
    countdown: true,
    startAt: 30000,
    milliseconds: false,
    interval: 1000
});
```

*Note that the `interval` option is only set to demonstrate the possibility to change this value. In this example, it is not really needed to alter the interval, however, if you have dozens of runners like this on one page, it might be wise to make the update interval a bit slower so that it won't eat up all the CPU.*


#### Initialize a normal count up runner with a custom formatter function that displays the time in minutes (with decimals):

```javascript
$('#runner').runner({
    format: function(value) {
        return (value / 1000) / 60;
    }
});
```


#### Initialize a count down runner that starts from 12 minutes and stops at 0, and alerts when the runner finishes:

```javascript
$('#runner').runner({
    countdown: true,
    startAt: 12 * 60 * 1000,
    stopAt: 0
}).bind('runnerStopped', function(ev, info) {
    // check if we have reached the finish, or if the runner was just paused
    if (info.time == 0) {
        alert('The eggs are now hard-boiled!');
    }
});
```

## Changelog

## Development

* Source hosted at [GitHub](https://github.com/jylauril/jquery-runner)

* Report issues, questions, feature requests on [GitHub Issues](https://github.com/jylauril/jquery-runner/issues)


## Licence

#### Dual licensed under the MIT and GPL licenses:

*   <http://www.opensource.org/licenses/mit-license.php>

*   <http://www.gnu.org/licenses/gpl.html>


## Author

[Jyrki Laurila](https://github.com/jylauril)
