# ChangeResolvers
Enables changes to be applied to files, under the following constraints:

1) The conflict resolvers must always operate in a conflict free manner. 
2) The sequence of changes may change the result, but any sequence of changes must be accepted. i.e., must be processed successfully and not fail.
3) It is possible that specific individual changes may be applied more than once. It is best if a specific change resolver is robust enough to be idempotent-- i.e., that only application of the change the first time has an effect, and subsequent application of the same change has no effect. However, this is not required. It *is* required that multiple applications of the same change not cause a failure. Presently, multiple applications of the same change only occur on a server or network failure.

These constraints impose limits on the design you chose for the data structure of the file contents.

Intended for use on both iOS and Server. 

On iOS, the intent is that use of the change resolver is predictive-- to give an estimate of what the final result will look like after later downloading. The later downloaded result should be identical if only this specific client is uploading changes.

On the server, the intent is that this is used to apply the final changes to files, from possibly multiple clients, for later downloading to iOS clients.


TODO: 

1) Need to add versions to change resolvers-- which will also go into the server database. I.e., so we can assess which version of a change resolver the server is compatible with.
