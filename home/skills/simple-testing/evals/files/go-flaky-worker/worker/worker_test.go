package worker

import (
	"context"
	"testing"
	"time"
)

func TestWorkerProcessesJob(t *testing.T) {
	var got []string
	w := New(func(j Job) { got = append(got, j.ID) })
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	w.Start(ctx)

	w.Submit(Job{ID: "a"})
	w.Submit(Job{ID: "b"})
	time.Sleep(time.Millisecond)

	if len(got) != 2 || got[0] != "a" || got[1] != "b" {
		t.Fatalf("got %v, want [a b]", got)
	}
}
