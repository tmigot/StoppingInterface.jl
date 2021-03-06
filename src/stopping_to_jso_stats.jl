using SolverTools

"""
Return the status in GenericStats from a Stopping.
"""
function status_stopping_to_stats(stp :: AbstractStopping)
 stp_status = status(stp)
 convert = Dict([(:Optimal, :first_order),
                 (:SubProblemFailure, :unknown),
                 (:SubOptimal, :acceptable),
                 (:Unbounded, :unbounded),
                 (:UnboundedPb, :unbounded),
                 (:Stalled, :stalled),
                 (:IterationLimit, :max_iter),
                 (:Tired, :max_time), #disapear from Stopping.jl#v0.2.5
                 (:TimeLimit, :max_time),
                 (:ResourcesExhausted, :max_eval), #disapear from Stopping.jl#v0.2.5
                 (:EvaluationLimit, :max_eval),
                 (:ResourcesOfMainProblemExhausted, :max_eval),
                 (:Infeasible, :infeasible),
                 (:DomainError, :exception),
                 (:StopByUser, :user),
                 (:Exception, :exception),
                 (:Unknown, :unknown)
                 ])
 return convert[stp_status]
end

"""
Initialize a GenericStats from Stopping
"""
function stopping_to_stats(stp :: NLPStopping)
    return GenericExecutionStats(status_stopping_to_stats(stp), 
                                 stp.pb,
                                 solution     = stp.current_state.x,
                                 objective    = stp.current_state.fx,
                                 primal_feas  = norm(stp.current_state.cx, Inf),
                                 dual_feas    = norm(stp.current_state.res, Inf),
                                 multipliers  = stp.current_state.lambda,
                                 iter         = stp.meta.nb_of_stop,
                                 elapsed_time = stp.current_state.current_time - stp.meta.start_time)
end

function stats_status_to_meta!(stp   :: AbstractStopping, 
                               stats :: GenericExecutionStats)
  return stats_status_to_meta!(stp, stats.status)
end

function stats_status_to_meta!(stp    :: AbstractStopping, 
                               status :: Symbol)
  #Update the meta boolean with the output message
  if status == :first_order stp.meta.optimal         = true end
  if status == :acceptable  stp.meta.suboptimal      = true end
  if status == :infeasible  stp.meta.infeasible      = true end
  if status == :small_step  stp.meta.stalled         = true end
  if status == :max_eval    stp.meta.resources       = true end
  if status == :max_iter    stp.meta.iteration_limit = true end
  if status == :max_time    stp.meta.tired           = true end
  if status ∈ [:neg_pred, 
               :not_desc]   stp.meta.fail_sub_pb     = true end
  if status == :unbounded   stp.meta.unbounded       = true end
  if status == :user        stp.meta.stopbyuser      = true end
  if status ∈ [:stalled, 
               :small_residual,
               :small_step]   stp.meta.stalled       = true end
  #if stats.status == :exception   stp.meta.exception       = true end #available ≥ 0.2.6

  return stp
end
