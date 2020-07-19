# ChangeResolvers
Enables changes to be applied to files, under the following constraints:

1) The conflict resolvers must always operate in a conflict free manner. 
2) The sequence of changes may change the result, but any sequence of changes must be accepted.
3) It is possible that specific individual changes may be applied more than once. It is best if a specific change resolver is robust enough to be idempotent-- i.e., that only application of the change the first time has an effect, subsequent application of the same change has no effect. However, this is not required. It *is* required that multiple applications of the same change not cause a failure. Presently, multiple applications of the same change only occur on a server or network failure.

These constraints impose limits on the design you chose for the data structure of the file contents.

Intended for use on both iOS and Server. 


TODO: 

1) Need to add versions to change resolvers-- which will also go into the server database. I.e., so we can assess which version of a change resolver the server is compatible with.
