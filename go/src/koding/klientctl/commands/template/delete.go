package template

import (
	"koding/klientctl/commands/cli"

	"github.com/spf13/cobra"
)

type deleteOptions struct {
	template string
	id       string
	force    bool
}

// NewDeleteCommand creates a command that is used to delete stack templates.
func NewDeleteCommand(c *cli.CLI) *cobra.Command {
	opts := &deleteOptions{}

	cmd := &cobra.Command{
		Use:   "delete",
		Short: "Delete a stack template",
		RunE:  deleteCommand(c, opts),
	}

	// Flags.
	flags := cmd.Flags()
	flags.StringVar(&opts.template, "template", "", "limit to template name")
	flags.StringVar(&opts.id, "id", "", "limit to template id")
	flags.BoolVar(&opts.force, "force", false, "confirm all questions")

	// Middlewares.
	cli.MultiCobraCmdMiddleware(
		cli.NoArgs, // No custom arguments are accepted.
	)(c, cmd)

	return cmd
}

func deleteCommand(c *cli.CLI, opts *deleteOptions) cli.CobraFuncE {
	return func(cmd *cobra.Command, args []string) error {
		return nil
	}
}
