this is a script, that will help you migrate your angular project, away from flex-layout, because it doesn't work with ssr.

## Migration
migrate flex-layout directives to css classes guide:

### Static Directives:

```html
fxFlex => class="flex-flex"
fxHide => class="flex-hide"
fxLayout="row" => class="flex-row"
fxLayout="column" => class="flex-column"
fxLayout="row wrap": => class="flex-row-wrap"
fxLayout="column wrap": => class="flex-column-wrap"
fxFill => class="flex-fill"
```

### Dynamic Directives:
```html
fxFlex="$x" => class="flex-flex-$x"
fxFlexAlign="$x" => class="flex-align-$x"
fxLayoutGap="$x" => style="gap: $x"
```

### Media Queries
you can use media queries with most of the classes above,
all you have to do is suffix them with desired mq for example:
```html
fxHide.lt-md => class="flex-hide-lt-md"
```
and the same is true for the majority of other classes

## Automation
luckily you don't have to do this tedious task by hand, there is a script that will do this for you, keep in mind that the migration is not perfect, and you still have to review the changes, and test to see if your layout looks correct in the browser, because flex-layout module sometimes adds extras css properties, and sometimes it doesn't, even if the directive is the same, in both cases. one good example is `fxFlexAlign` and `fxFlex` sometimes it adds:
```css 
display: flex;
``` 
and sometimes not, and the script will warn you about it, to just double check.

to use the script, make sure it is executable:
```bash
chmod +x ./scripts/flex-layout*
```

then run it:
```bash
./scripts/flex-layout-stub.sh <module-path>
# example: ./scripts/flex-layout-stub.sh src/app/core
```