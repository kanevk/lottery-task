import React, { Component, useState } from 'react';
import './App.css';

const CellComponent = ({ number, selected, numberToggled, selectionDisabled }) => {
    const classNames = `cell ${selected ? 'selected' : ''}`

    return (
        <button className={classNames}
            key={number}
            disabled={selected ? false : selectionDisabled}
            onClick={() => numberToggled(number)}
        >{number}</button>
    )
}

const TicketComponent = () => {
    const [selectedNumbers, changeSelectedNumbers] = useState([]);
    const selectedCount = selectedNumbers.length;
    const numberToggled = (number) => {
        if (selectedNumbers.includes(number)) {
            changeSelectedNumbers(selectedNumbers.filter((n) => n !== number))
        } else {
            changeSelectedNumbers([number, ...selectedNumbers])
        }
    }

    return (
        <div className="Ticket">
            <div className="Ticket-body">
                {
                    [...Array(49).keys()].map((i) =>
                        CellComponent({
                            numberToggled,
                            number: i + 1,
                            selected: selectedNumbers.includes(i + 1),
                            selectionDisabled: selectedCount === 6,
                        })
                    )
                }
            </div>
            <button className="button" disabled={selectedCount !== 6}>Enroll</button>
            <p>{selectedCount}/6 selected</p>
        </div>
    )
}

class App extends Component {
    render () {
        return (
            <div className="App">
                <div className="App-header">
                    <h1>Lottery 6/49</h1>
                </div>
                <div className="App-body">
                    <TicketComponent />
                    <div className="DrawSide">
                        <button className="button big-red"> Find the winner </button>
                    </div>
                </div>
            </div>
        );
    }
}

export default App;
