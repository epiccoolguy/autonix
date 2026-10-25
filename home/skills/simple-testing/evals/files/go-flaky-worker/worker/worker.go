package worker

import "context"

type Job struct {
	ID string
}

type Worker struct {
	jobs   chan Job
	handle func(Job)
}

func New(handle func(Job)) *Worker {
	return &Worker{jobs: make(chan Job, 16), handle: handle}
}

func (w *Worker) Start(ctx context.Context) {
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case j := <-w.jobs:
				w.handle(j)
			}
		}
	}()
}

func (w *Worker) Submit(j Job) {
	w.jobs <- j
}
