/**
 * jQuery Runner Plugin v1.0
 *
 * http://
 *
 * Copyright (c) 2011 Jyrki Laurila
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

;(function($) {
    var steps = [3600000, 60000, 1000, 10],
        sep = [':', ':', '.', ''],
        up = false,
        settings = {
            autostart: false,
            interval: 20,
            countdown: false,
            stopAt: null,
            startAt: 0,
            format: null
        };
    
    function pad(n) {
        return (n < 10 ? '0' : '') + n;
    }
    
    function formatTime(val) {
        var i = 0,
            v = 0,
            l = steps.length,
            s, str = '', p = '';
        if (val < 0) {
            val = Math.abs(val);
            p = '-';
        }
        for (; i < l; i++, v = 0) {
            s = steps[i];
            if (val >= s) {
                v = Math.floor(val / s);
                val -= v * s;
            }
            if (v || i > 1 || str) str += pad(v) + sep[i];
        }
        return p + str;
    }
    
    function format(d, val) {
        var f = d.settings.format;
        return typeof f == 'function' ? f(val, formatTime) : formatTime(val);
    }

    function updateTime(t) {
        if (!up) {
            up = true;
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
            up = false;
        }
    }
    
    function setVal(c, val) {
        var d = data(c);
        c.each(function(t, e) {
            t = $(e);
            t[(t.is('input') ? 'val' : 'text')](format(d, val));
        });
    }
    
    function data(t) {
        return t.data('runner');
    }
    
    function fire(t, ev) {
        t.trigger(ev, methods.info(t));
    }
    
    var methods = {
        init: function(options) {
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
            if (d.settings.autostart) methods.start(this);
            
            return this;
        },
        start: function(t) {
            t = t || this;
            var d = data(t);
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
                l = d.lastLap || 0;
            return {
                running: d.running,
                time: d.total,
                formattedTime: format(d, d.total),
                startTime: d.startTime,
                lapTime: l,
                formattedLapTime: format(d, l),
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
