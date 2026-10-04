#[derive(Debug, Clone, PartialEq)]
pub enum Job {
    Queued,
    Running { worker: u32 },
    Done,
    Failed { reason: String },
}

pub fn label(job: &Job) -> &'static str {
    match job {
        Job::Queued => "queued",
        Job::Running { .. } => "running",
        Job::Done => "done",
        Job::Failed { .. } => "failed",
    }
}

pub fn is_finished(job: &Job) -> bool {
    match job {
        Job::Queued | Job::Running { .. } => false,
        Job::Done | Job::Failed { .. } => true,
    }
}
