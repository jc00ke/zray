# Z-Ray

Video overlay, similar to Amazon's X-Ray feature.

| At    | Until | Button Text         | Asset                   |
| ----- | ----- | ------------------- | ----------------------- |
| 0     | 0.05  | no button           |                         |
| 0.05  | 0.15  | Click for Location  | [^1] Text               |
| 0.15  | 0.25  | Click for Dancer    | [^2] Text               |
| 0.25  | 0.35  | Click for Photo     | Photo 1                 |
| 0.35  | 0.45  | Click for Video     | Video 1                 |
| 0.45  | 0.55  | Click for Photo     | Photo 2                 |
| 0.55  | 1.05  | Click for Video     | Video 2                 |
| 1.05  | 1.15  | Click for Link      | [www.orcas.dance]       |
| 1.15  | end   | no button           |                         |

[^1]: "Filmed at the Orcas Center, Madrona Room on December 19, 2019"
[^2]: "Aristotle Luna, age 16, dancer with the Island Inspiration All-Stars"

## Dev

```
> yarn
> ./bin/server
```

## Building

```
> yarn parcel build index.html
> ls dist/
```

## Notes and References

* https://jsfiddle.net/jc00ke/h6n02xwL/
* https://github.com/FrankelJb/elm-media
* https://www.tailwindtoolbox.com/components/modal
* https://tailwind.run/ke4wNC/4
* https://github.com/JoelQ/fourier-art/commit/1acfc497717f7e530f7d745b5c7eb630512cbd6c
