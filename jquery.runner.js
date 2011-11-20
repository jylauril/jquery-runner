/**
 * jQuery Runner Plugin v1.0
 *
 * https://github.com/jylauril/jquery-runner
 *
 * Copyright (c) 2011 Jyrki Laurila
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

;(function($) {
    var steps = [3600000, 60000, 1000, 10],
        separator = ['', ':', ':', '.'],
        updating = false,
        settings = {
            autostart: false,
            interval: 20,
            countdown: false,
            stopAt: null,
            startAt: 0,
            milliseconds: true,
            format: null
        };
    
    function pad(num) {
        return (num < 10 ? '0' : '') + num;
    }
    
    function formatTime(val, ms) {
        var i = 0,
            v = 0,
            len = steps.length,
            step, output = '', prefix = '';
        if (val < 0) {
            val = Math.abs(val);
            prefix = '-';
        }
        for (; i < len; i++, v = 0) {
            step = steps[i];
            if (val >= step) {
                v = Math.floor(val / step);
                val -= v * step;
            }

            if ((v || i > 1 || output) && (i != len-1 || ms)) {
                output += (output ? separator[i] : '') + pad(v);
            }
        }
        return prefix + output;
    }
    
    function format(d, val) {
        var set = d.settings,
            func = set.format,
            ms = set.milliseconds;
        return typeof f == 'function' ? f(val, formatTime, ms) : formatTime(val, ms);
    }

    function updateTime(t) {
        if (!updating) {
            updating = true;
            var d = data(t),
                set = d.settings,
                n = $.now(),
                sa = set.stopAt,
                cd = set.countdown,
                delta = n - d.lastTime;
            d.lastTime = n;
            if (cd) d.total -= delta;
            else d.total += delta;
            if (sa !== null && ((cd && d.total <= sa) || (!cd && d.total >= sa))) {
                d.total = sa;
                methods.stop(t);
            }
            setVal(t, d.total);
            updating = false;
        }
    }
    
    function setVal(t, val) {
        var d = data(t);
        t.each(function(item, element) {
            item = $(element);
            item[(item.is('input') ? 'val' : 'text')](format(d, val));
        });
    }
    
    function data(t) {
        return t.data('runner');
    }
    
    function fire(t, ev) {
        t.trigger(ev, methods.info(t));
    }
    
    var methods = {
        init: function(options, start) {
            var o = data(this) || {},
                d = {
                    total: 0,
                    lastTime: 0,
                    startTime: 0,
                    lapTime: 0,
                    settings: $.extend({}, settings, o.settings, options)
                };
                
            this.data('runner', d);
            if (!d.startTime) setVal(this, d.settings.startAt);
            if (start || d.settings.autostart) methods.start(this);
            
            return this;
        },
        start: function(t) {
            t = t || this;
            var d = data(t);
            if (!d) return methods.init({}, true);
            if (!d.running) {
                d.running = true;
                if (!d.startTime) methods.reset(t);
                d.lastTime = $.now();
                d.interval = setInterval(function() { updateTime(t); }, d.settings.interval);
                fire(t, 'runnerStarted');
            }
            return t;
        },
        stop: function(t) {
            t = t || this;
            var d = data(t);
            if (d.running) {
                d.running = false;
                clearInterval(d.interval);
                updateTime(t);
            }
            fire(t, 'runnerStopped');
            return t;
        },
        lap: function(t) {
            t = t || this;
            var d = data(t),
                nl = d.lastTime,
                lap = nl - d.lapTime;
            
            if (d.running || lap) {
                d.lastLap = lap;
                d.lapTime = nl;
            }
            nl = format(d, d.lastLap);
            fire(t, 'runnerLap');
            return nl;
        },
        toggle: function(t) {
            t = t || this;
            var d = data(t);
            return methods[(d.running ? 'stop' : 'start')](t);
        },
        reset: function(t) {
            t = t || this;
            var d = data(t);
            d.startTime = d.lapTime = d.lastTime = $.now();
            d.total = d.settings.startAt;
            setVal(t, d.total);
            return t;
        },
        info: function(t) {
            t = t || this;
            var d = data(t),
                lap = d.lastLap || 0;
            return {
                running: d.running,
                time: d.total,
                formattedTime: format(d, d.total),
                startTime: d.startTime,
                lapTime: lap,
                formattedLapTime: format(d, lap),
                settings: d.settings
            }
        }
    };

    $.fn.runner = function(method) {
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' +  method + ' does not exist on jQuery.runner');
        }
    };

})(jQuery);
