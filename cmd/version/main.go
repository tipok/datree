package version

import (
	"fmt"

	"github.com/datreeio/datree/bl/messager"
	"github.com/spf13/cobra"
)

type Messager interface {
	LoadVersionMessages(messages chan *messager.VersionMessage, cliVersion string)
}

type Printer interface {
	PrintMessage(messageText string, messageColor string)
}
type VersionCommandContext struct {
	CliVersion string
	Messager   Messager
	Printer    Printer
}

func version(ctx *VersionCommandContext) {
	messages := make(chan *messager.VersionMessage, 1)
	go ctx.Messager.LoadVersionMessages(messages, ctx.CliVersion)
	fmt.Println(ctx.CliVersion)
	msg, ok := <-messages
	if ok {
		ctx.Printer.PrintMessage(msg.MessageText+"\n", msg.MessageColor)
	}
}

func New(ctx *VersionCommandContext) *cobra.Command {
	var versionCmd = &cobra.Command{
		Use:   "version",
		Short: "Print the version number",
		Long:  "Print the version number",
		Run: func(cmd *cobra.Command, args []string) {
			version(ctx)
		},
	}
	return versionCmd
}
