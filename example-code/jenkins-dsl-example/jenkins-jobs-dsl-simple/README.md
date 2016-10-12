jenkins-jobs-dsl-simple
=============
This is a simple example of the Jenkins DSL. You can define common reusable jobs for your applications. Note that this isn't full blown Groovy. You can't import additional libraries. There is also some gotchas around itterables as `.each` type of loops will sometimes give mixed results. Keep to old school `for(int i = 0; i < collection.length; i++)` type loops.

Here is an article that gives examples. We used this as a source of inspiration for our actual implementation. http://marcesher.com/2016/06/13/jenkins-as-code-creating-reusable-builders/