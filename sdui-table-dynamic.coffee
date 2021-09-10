import React, {Suspense, lazy} from 'react'

suspend = (WrappedComponent) -> (props) ->
  <Suspense fallback={-> <div>Loading...</div>}><WrappedComponent {props...}/></Suspense>

export MeteorDataAutoTable = suspend lazy -> import('./imports/ui/MeteorDataAutoTable')
export EditableDataTable = suspend lazy -> import('./imports/ui/EditableDataTable')
export DataTable = suspend lazy -> import('./imports/ui/DataTable')