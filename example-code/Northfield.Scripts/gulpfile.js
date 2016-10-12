var gulp = require('gulp');

var shell = require('gulp-shell')

var run = require('gulp-run');

var notify = require('gulp-notify');



gulp.task('rspec', function () {
	return gulp.src('')
		.pipe(shell([ "rspec \-\-format doc" ]))
		.on('error', notify.onError({
			title: "Testing Failed",
			message: "Error(s) occurred during testing..."
		}));
});

gulp.task('watch', function() {
    gulp.watch(['spec/**/*.rb', 'lib/**/*.rb'], ['rspec']);
});
